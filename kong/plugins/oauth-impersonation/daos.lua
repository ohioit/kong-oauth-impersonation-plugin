local SCHEMA = {
    primary_key = { "id" },
    table = "oauth2_impersonation",
    cache_key = { "token_id" },
    fields = {
        id = { type = "id", dao_insert_value = true },
        token_id = {type = "id", foreign = "oauth2_tokens:id", unique = true},
        impersonated_userid = {type = "string", required = true, unique = false},
        created_at = {type = "timestamp", immutable = true, dao_insert_value = true}
    }
}

return {oauth2_impersonation = SCHEMA}