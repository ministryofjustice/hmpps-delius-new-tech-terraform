{
  "Version": "2012-10-17",
  "Statement": [
      {
      "Action": [
        "es:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${domain_arn}",
        "${domain_arn}/*"
      ]
    }
  ]
}