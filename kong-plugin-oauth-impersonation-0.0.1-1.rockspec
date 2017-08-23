local pluginName = "oauth-impersonation"

package = "kong-plugin-" .. pluginName
version = "0.0.1-1"
supported_platforms = {"linux", "macosx"}
source = {
    url = "git@github.com:ohioit/kong-" .. pluginName .. "-plugin.git"
}
description = {
    summary = "Kong OAuth Impersonation Plugin",
    detailed = [[
        Allow an impersonated user to be provisioned to the gateway
        to show up in `x-authenticated-userid` headers rather than the
        actually logged in user.
    ]]
}
dependencies  = {}
build = {
    type = "builtin",
    modules = {
        ["kong.plugins."..pluginName..".access"] = "kong/plugins/"..pluginName.."/access.lua",
        ["kong.plugins."..pluginName..".api"] = "kong/plugins/"..pluginName.."/api.lua",
        ["kong.plugins."..pluginName..".daos"] = "kong/plugins/"..pluginName.."/daos.lua",
        ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
        ["kong.plugins."..pluginName..".migrations.cassandra"] = "kong/plugins/"..pluginName.."/migrations/cassandra.lua",
        ["kong.plugins."..pluginName..".migrations.postgres"] = "kong/plugins/"..pluginName.."/migrations/postgres.lua",
        ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
    }
}
