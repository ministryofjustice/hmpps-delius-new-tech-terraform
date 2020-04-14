{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${cloudplatform_account_id}:root",
          "arn:aws:iam::${delius_iam_account_id}:root"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}