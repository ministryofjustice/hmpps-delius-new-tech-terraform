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
        "logs:PutLogEvents",
        "application-autoscaling:*",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm"
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
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/web/application_secret",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/web/custody_api_username",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/web/custody_api_password",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/monitoring/analytics/google_id",
          "arn:aws:kms:${region}:${aws_account_id}:alias/aws/ssm"
      ]
    }
  ]
}