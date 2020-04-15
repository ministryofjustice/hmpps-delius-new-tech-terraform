{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CrossIAMPermissions",
            "Effect": "Allow",
            "Action": [
                "es:ESHttpHead",
                "es:ESHttpPost",
                "es:ESHttpGet",
                "es:ESHttpPatch",
                "es:ESHttpPut"
            ],
            "Resource":"arn:aws:es:${region}:${account_id}:domain/${domain}" 
        },
        {
            "Sid": "CrossIAMPermissionsRead",
            "Effect": "Allow",
            "Action": [
                "es:Describe*",
                "es:List*"
            ],
            "Resource": "*"
        }
    ]
}