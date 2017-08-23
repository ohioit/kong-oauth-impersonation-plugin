local utils = require "kong.tools.utils"
local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"

local ngx_set_header = ngx.req.set_header

local load_impersonation = function(token)
    local impersonation, err = singletons.dao.oauth2_impersonation:find_all({ token_id = token })

    if err then
        return nil, err
    end

    return impersonation[1]
end

local _M = {}

function _M.execute(conf)
    if ngx.ctx.authenticated_token then
        local token = ngx.ctx.authenticated_token
        local cache_key = singletons.dao.oauth2_impersonation:cache_key(token.id)

        impersonation, err = singletons.cache:get(cache_key, nil, load_impersonation, token.id)
        if impersonation then
            ngx_set_header("x-authenticated-actual-userid", token.authenticated_userid)
            ngx_set_header("x-authenticated-userid", impersonation.impersonated_userid)
        elseif err then
            return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
        end
    end
end

return _M
