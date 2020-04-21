{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:sts::${cloudplatform_account_id}:assumed-role/${cloudplatform_offender_search_role_name}/kiam-kiam",
          "arn:aws:iam::${delius_iam_account_id}:root"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}