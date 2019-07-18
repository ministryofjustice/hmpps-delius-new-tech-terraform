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

data "template_file" "cnotesexec_policy_template" {
  template = "${file("${path.module}/templates/iam/cnotesexec_policy.tpl")}"
  vars     = {}
}

# Case notes task definition template
data "template_file" "casenotes_task_def_template" {
  template = "${file("templates/ecs/casenotes_task_def.tpl")}"

  vars {
    region         = "${var.region}"
    container_name = "casenotes"
    image_url      = "${var.casenotes_conf["image"]}"
    image_version  = "${var.casenotes_conf["image_version"]}"
    log_group_name = "${var.environment_name}/casenotes"
    memory         = "${var.casenotes_conf["memory"]}"
  }
}