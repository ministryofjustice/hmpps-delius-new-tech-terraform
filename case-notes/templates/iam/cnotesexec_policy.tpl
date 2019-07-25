{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "kms:Decrypt"
      ],
      "Resource": [
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/casenotes_user",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/casenotes_password",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/casenotes/nomis_token",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/casenotes/nomis_private_key",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/casenotes/nomis_public_key",
          "arn:aws:kms:${region}:${aws_account_id}:alias/aws/ssm"
      ]
    }
  ]
}