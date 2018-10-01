# EC2 role

resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name      = "${aws_iam_role.ec2.name}"
  role      = "${aws_iam_role.ec2.name}"
}

resource "aws_iam_role" "ec2" {
  name               = "${local.environment_name}-delius-api-beanstalk-ec2-role"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = "${file("${path.module}/../policies/ec2_assume_role_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "web-tier" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "multicontainer-docker" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "worker-tier" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "container-registry" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "parameter-store" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# Service role

resource "aws_iam_instance_profile" "beanstalk_service" {
  name       = "${aws_iam_role.service.name}"
  role       = "${aws_iam_role.service.name}"
}

resource "aws_iam_role" "service" {
  name = "${local.environment_name}-delius-api-beanstalk-service-role"
  description = "Allows Elastic Beanstalk to create and manage AWS resources on your behalf."
  assume_role_policy = "${file("${path.module}/../policies/beanstalk_assume_role_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "enhanced-health" {
  role       = "${aws_iam_role.service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = "${aws_iam_role.service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

