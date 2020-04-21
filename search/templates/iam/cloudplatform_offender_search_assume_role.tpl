{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${cloudplatform_account_id}:role/${cloudplatform_offender_search_role_name}",
          "arn:aws:iam::${delius_iam_account_id}:root"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}