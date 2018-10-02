#########################
# CLOUDWATCH GROUP
#########################

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "${local.environment_name}/vpc_flow_logs"
  retention_in_days = "${var.cloudwatch_log_retention}"
  tags              = "${merge(var.tags, map("Name", "vpc_flow_logs"))}"
}

##########################
#  VPC FLOW LOGS
##########################

module "vpcflowlog_iam_role" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//role"
  rolename   = "${local.environment_name}-vpcflowlog"
  policyfile = "vpcflowlog_assume_role.json"
}

module "vpcflowlog_iam_role_policy" {
  source     = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam//rolepolicy"
  policyfile = "${file("policies/vpcflowlog_role_policy.json")}"
  rolename   = "${module.vpcflowlog_iam_role.iamrole_id}"
}

resource "aws_flow_log" "environment" {
  log_group_name = "${aws_cloudwatch_log_group.cloudtrail.name}"
  iam_role_arn   = "${module.vpcflowlog_iam_role.iamrole_arn}"
  vpc_id         = "${module.network.vpc_id}"
  traffic_type   = "ALL"
}

