return {
    {
        name = "2017-08-14-150200_init_impersonation_table",
        up = [[
            CREATE TABLE IF NOT EXISTS oauth2_impersonation (
                id uuid
                token_id uuid,
                impersonated_userid text,
                created_at timestamp without time zone default (CURRENT_TIMESTAMP(0) at time zone 'utc'),
                PRIMARY KEY (id)
            );
        ]],
        down = [[
            DROP TABLE oauth2_impersonation;
        ]]
    }
}