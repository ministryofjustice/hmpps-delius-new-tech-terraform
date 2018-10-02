# Shared data and constants

locals {
  application_name = "delius-api"
  eb_environment_name = "${local.environment_name}"
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${local.environment_name}"
  }
}

data "aws_subnet_ids" "private" {
  tags = {
    Type = "private"
  }
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_subnet_ids" "public" {
  tags = {
    Type = "public"
  }
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "ec2" {
  tags = {
    Type = "private"
  }
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "elb" {
  tags = {
    Type = "public"
  }
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_elastic_beanstalk_solution_stack" "docker" {
  most_recent = true
  name_regex  = "^64bit Amazon Linux *.* v2.*.* running Docker *.*.*-ce$"
}

# The Delius API application

resource "aws_elastic_beanstalk_application" "delius-api" {
  name        = "delius-api"
  description = "Delius API"
}

# The elasticbeanstalk environment

resource "aws_elastic_beanstalk_environment" "eb_environment" {
  name = "delius-api-${local.eb_environment_name}"
  application = "${local.application_name}"
  solution_stack_name = "${data.aws_elastic_beanstalk_solution_stack.docker.name}"

  # Settings

  # ASG
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.delius_api_min_asg_size}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.delius_api_max_asg_size}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${local.environment_name}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_role.ec2.name}"
  }

  # ASG launch configuration

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.delius_api_instance_type}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${data.aws_security_group.ec2.id}"
  }
  # Workaround for https://github.com/terraform-providers/terraform-provider-aws/issues/555
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SSHSourceRestriction"
    value     = "tcp,22,22,255.255.255.254/31" # 0 usable IPs, the EC2 SG does the real subnet.
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "MonitoringInterval"
    value     = "1 minute"
  }

  # Dynamic autoscaling triggers
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "CPUUtilization"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = "${var.delius_api_lower_cpu_trigger}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "${var.delius_api_upper_cpu_trigger}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Percent"
  }

  # EC2
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${data.aws_vpc.vpc.id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", data.aws_subnet_ids.private.ids)}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${join(",", data.aws_subnet_ids.public.ids)}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  # EB
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_role.service.name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "7"
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "ConfigDocument"
    value     = "${file("health_config.json")}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = "7"
  }

  # ELB
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = "true"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${data.aws_security_group.elb.id}"
  }
  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${data.aws_security_group.elb.id}"
  }

  # Application settings
  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "/api/health"
  }

  tags        = "${var.tags}"

  depends_on = ["aws_elastic_beanstalk_application.delius-api"]
}

