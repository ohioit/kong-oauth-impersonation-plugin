local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.oauth-impersonation.access"

local OAuthImpersonationPlugin =  BasePlugin:extend()

function OAuthImpersonationPlugin:new()
    OAuthImpersonationPlugin.super.new(self, "userinfo")
end

function OAuthImpersonationPlugin:access(conf)
    OAuthImpersonationPlugin.super.access(self)
    access.execute(conf)
end

OAuthImpersonationPlugin.PRIORITY = 875

return OAuthImpersonationPlugin
