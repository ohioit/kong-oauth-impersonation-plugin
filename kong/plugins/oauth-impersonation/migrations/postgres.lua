return {
    {
        name = "2017-08-14-145700_init_impersonation_table",
        up = [[
            CREATE TABLE IF NOT EXISTS oauth2_impersonation (
                id uuid,
                token_id uuid REFERENCES oauth2_tokens (id) ON DELETE CASCADE,
                impersonated_userid text NOT NULL,
                created_at timestamp,
                PRIMARY KEY (id)
            );
        ]],
        down = [[
            DROP TABLE oauth2_impersonation;
        ]]
    }
}