{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllESActionsForThisResourceOnly",
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${region}:${account_id}:domain/${domain}/*"
        }
    ]
}