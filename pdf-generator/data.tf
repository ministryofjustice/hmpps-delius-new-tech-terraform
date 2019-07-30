# Load in VPC state data for subnet placement
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in VPC security groups to reference bastion ssh inbound group for ecs hosts
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in shared ECS cluster state file for target cluster arn
data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "ecs-cluster/terraform.tfstate"
    region = "${var.region}"
  }
}

# Get current context for things like account id
data "aws_caller_identity" "current" {}

# Template files for casenotes task role and execution role definitions
data "template_file" "ecstasks_assumerole_template" {
  template = "${file("${path.module}/templates/iam/ecstasks_assumerole_policy.tpl")}"
  vars     = {}
}

data "template_file" "pdf_policy_template" {
  template = "${file("${path.module}/templates/iam/pdf_exec_policy.tpl")}"

  vars = {}
}

# Case notes task definition template
data "template_file" "pdf_task_def_template" {
  template = "${file("templates/ecs/pdfgenerator_task_def.tpl")}"

  vars {
    region              = "${var.region}"
    aws_account_id      = "${data.aws_caller_identity.current.account_id}"
    environment_name    = "${var.environment_name}"
    project_name        = "${var.project_name}"
    container_name      = "pdfgenerator"
    image_url           = "${var.pdfgenerator_conf["image"]}"
    image_version       = "${var.pdfgenerator_conf["image_version"]}"
    log_group_name      = "${local.name_prefix}-pdfgen-pri-cwl"
    env_debug_log       = "${var.pdfgenerator_conf["env_debug_log"]}"
  }
}
