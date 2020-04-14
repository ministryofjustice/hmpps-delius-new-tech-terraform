{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::570551521311:Admins",
          "arn:aws:iam::754256621582:remote-pcs-newtech-elasticsearch-service-role-${environment_name}"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
