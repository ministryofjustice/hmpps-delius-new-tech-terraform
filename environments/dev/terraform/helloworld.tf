# Hello world sample application in the nDelius stage environment

# Elastic beanstalk
locals {
  helloworld_application_name = "delius-helloworld"
  helloworld_eb_environment_name = "delius-helloworld-dev"
}

# Security groups

resource "aws_security_group" "elb" {
  name        = "${local.helloworld_application_name}-elb"
  vpc_id      = "${module.network.vpc_id}"
  description = "ELB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.tags, map("Name", "${local.helloworld_application_name}_elb"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ec2" {
  name        = "${local.helloworld_application_name}-ec2"
  vpc_id      = "${module.network.vpc_id}"
  description = "elasticbeanstalk EC2 instances"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(local.tags, map("Name", "${local.helloworld_application_name}_ec2"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic beanstalk environments

# This resource is shared with multiple environments
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "${local.helloworld_application_name}"
  description = "Test of beanstalk deployment"
}

# Stage environment

resource "aws_elastic_beanstalk_environment" "eb_environment" {
  name = "${aws_elastic_beanstalk_application.eb_app.name}"
  application = "${local.helloworld_application_name}"
  solution_stack_name = "64bit Amazon Linux 2017.09 v2.9.2 running Docker 17.12.0-ce"

  # Settings

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${module.network.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", list(module.network.private_subnet_a_id, module.network.private_subnet_b_id))}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${join(",", list(module.network.public_subnet_a_id, module.network.public_subnet_b_id))}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.ec2.id}"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${aws_security_group.elb.id}"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${aws_security_group.elb.id}"
  }
  tags        = "${local.tags}"
}

resource "aws_elastic_beanstalk_application_version" "latest" {
  name        = "latest"
  application = "${aws_elastic_beanstalk_application.eb_app.name}"
  description = "Version latest of app ${aws_elastic_beanstalk_application.eb_app.name}"
  bucket      = "hmpps-probation-artefacts"
  key         = "Dockerrun.aws.json.zip"
}
