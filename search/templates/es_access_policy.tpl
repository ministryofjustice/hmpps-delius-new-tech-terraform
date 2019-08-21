{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAuthenticatedKibanaRoleAccess",
            "Effect":"Allow",
            "Principal": {
                "AWS": [
                    "${kibana_role}"
                ]
            },
            "Action":"es:*",
            "Resource":"arn:aws:es:${region}:${account_id}:domain/${domain}" 
        }
    ]
}