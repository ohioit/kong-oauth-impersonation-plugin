local crud = require "kong.api.crud_helpers"
local responses = require "kong.tools.responses"
local lapis_helpers = require "lapis.application"
local printable_mt = require "kong.tools.printable"

local yield_error = lapis_helpers.yield_error

-- Header parsing taken from the OAuth2 plugin
-- and altered slightly for Lapis.
local parse_token = function(self)
    local result = self.params['access_token']

    if not result then
        local authorization = self.req.headers['authorization']

        if authorization then
            local parts = {}
            for v in authorization:gmatch("%S+") do -- Split by space
                table.insert(parts, v)
            end
            if #parts == 2 and (parts[1]:lower() == "token" or parts[1]:lower() == "bearer") then
                result = parts[2]
            end
        end 
    end

    return result
end

local find_token = function(self, dao_factory, helpers, targetRequired)
    local token = parse_token(self)
    local err = nil

    local targetUser = self.params['targetUser']
    local provisionKey = self.params['provision_key']

    if (not targetUser and targetRequired) and provisionKey then
        return nil, responses.send_HTTP_BAD_REQUEST("missing required parameters")
    end

    if not token then
        return nil, responses.send_HTTP_UNAUTHORIZED("full authentication required.")
    end

    token, err = dao_factory.oauth2_tokens:find_all({access_token = token})

    if err then
        return nil, responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end

    token = token[1]

    if not token then
        return nil, responses.send_HTTP_UNAUTHORIZED("token invalid.")
    end

    local api, err = dao_factory.apis:find_all({ name = self.params.api })

    if err then
        return nil, responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end

    api = api[1]

    if not api then
        return nil, responses.send_HTTP_NOT_FOUND("api not found.")
    end

    local plugin, err = crud.find_by_id_or_field(dao_factory.plugins, {
        api_id = api.id
    }, "oauth2", "name")

    if err then
        return nil, responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end

    plugin = plugin[1]

    if not plugin then
        return nil, responses.send_HTTP_NOT_FOUND("OAuth 2.0 is not enabled for this API.")
    end

    if provisionKey ~= plugin.config.provision_key then
        return nil, responses.send_HTTP_FORBIDDEN("Provision key is not valid.")
    end

    return token, nil
end

local unimpersonate = function(self, dao_factory, helpers)
    local token, err = find_token(self, dao_factory, helpers, false)

    if err then
        return err
    end

    local impersonation, err = dao_factory.oauth2_impersonation:find_all({
        token_id = token.id
    })

    if err then
        return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
    end

    impersonation = impersonation[1]

    if impersonation then
        local result, err = dao_factory.oauth2_impersonation:delete({
            id = impersonation.id
        })

        if err then
            return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
        end             
    else
        return responses.send_HTTP_NOT_FOUND("user is not impersonated")
    end

    return responses.send_HTTP_NO_CONTENT()
end

return {
    ["/apis/:api/oauth2/impersonate/:targetUser"] = {
        POST = function(self, dao_factory, helpers)
            ngx.log(ngx.DEBUG, "Impersonating user " .. self.params.targetUser .. "...")
            local token, err = find_token(self, dao_factory, helpers, true)

            if err then
                return err
            end

            local impersonation, err = dao_factory.oauth2_impersonation:find_all({
                token_id = token.id
            })

            if err then
                return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
            end

            impersonation = impersonation[1]

            if impersonation then
                local result, err = dao_factory.oauth2_impersonation:update({
                    impersonated_userid = self.params.targetUser
                }, {
                    token_id = token.id
                })

                if err then
                    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
                end             
            else
                local result, err = dao_factory.oauth2_impersonation:insert({
                    token_id = token.id,
                    impersonated_userid = self.params.targetUser
                })

                if err then
                    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
                end
            end

            return responses.send_HTTP_CREATED()
        end,

        DELETE = unimpersonate
    },
    ["/apis/:api/oauth2/impersonate"]  = {
        DELETE = unimpersonate
    }
}