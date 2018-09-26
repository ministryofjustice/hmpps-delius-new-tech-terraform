# Shared data and constants

data "aws_vpc" "vpc" {
  tags = {
    Name = "${local.environment_name}"
  }
}

# ELB Security group

resource "aws_security_group" "elb" {
  name        = "${local.environment_name}-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "ELB"
  tags = "${merge(var.tags, map("Name", "${local.environment_name}_elb", "Type", "public"))}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "elb_ssh_from_whitelist" {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.elb.id}"
  cidr_blocks = ["${var.whitelist_cidrs}"]
  type = "ingress"
}

resource "aws_security_group_rule" "elb_http_from_whitelist" {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.elb.id}"
  cidr_blocks = ["${var.whitelist_cidrs}"]
  type = "ingress"
}

resource "aws_security_group_rule" "elb_http_from_world" {
  count = "${var.world_access ? 1 : 0}"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.elb.id}"
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "elb_https_from_whitelist" {
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.elb.id}"
  cidr_blocks = ["${var.whitelist_cidrs}"]
  type = "ingress"
}

resource "aws_security_group_rule" "elb_all_to_anywhere" {
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  security_group_id = "${aws_security_group.elb.id}"
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

# EC2 Security group

resource "aws_security_group" "ec2" {
  name        = "${local.environment_name}-ec2"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "elasticbeanstalk EC2 instances"
  tags = "${merge(var.tags, map("Name", "${local.environment_name}_ec2", "Type", "private"))}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ec2_all_to_anywhere" {
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  security_group_id = "${aws_security_group.ec2.id}"
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

resource "aws_security_group_rule" "ec2_ssh_from_ci" {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.ec2.id}"
  cidr_blocks = ["${var.ci_vpc_cidr}"]
  type = "ingress"
}

resource "aws_security_group_rule" "ec2_http_from_ci" {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.ec2.id}"
  cidr_blocks = ["${var.ci_vpc_cidr}"]
  type = "ingress"
}

resource "aws_security_group_rule" "ec2_https_from_ci" {
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = "${aws_security_group.ec2.id}"
  cidr_blocks = ["${var.ci_vpc_cidr}"]
  type = "ingress"
}

resource "aws_security_group_rule" "ec2_ssh_from_bastion" {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.ec2.id}"
  cidr_blocks = ["${var.bastion_vpc_cidr}"]
  type = "ingress"
}

# DB Security group

resource "aws_security_group" "db" {
  name        = "${local.environment_name}-db"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "RDS instances"
  tags = "${merge(var.tags, map("Name", "${local.environment_name}_db", "Type", "DB"))}"
  lifecycle {
    create_before_destroy = true
  }
}

