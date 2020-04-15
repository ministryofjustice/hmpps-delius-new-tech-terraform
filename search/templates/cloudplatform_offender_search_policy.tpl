{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CrossIAMPermissionsElasticsearch",
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
            "Sid": "CrossIAMPermissionsElasticsearchRead",
            "Effect": "Allow",
            "Action": [
                "es:Describe*",
                "es:Get*",
                "es:List*",
                
            ],
            "Resource": "*"
        },
        {
            "Sid": "CrossIAMPermissionsCloudwatch",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:List*",
                "cloudwatch:Describe*",
                "cloudwatch:Get*"
            ],
            "Resource": "*"
        }
    ]
}
