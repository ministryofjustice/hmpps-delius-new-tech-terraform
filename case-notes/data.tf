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

  vars = {
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    region           = "${var.region}"
    project_name     = "${var.project_name}"
  }
}

# Case notes task definition template
data "template_file" "casenotes_task_def_template" {
  template = "${file("templates/ecs/casenotes_task_def.tpl")}"

  vars {
    region              = "${var.region}"
    aws_account_id      = "${data.aws_caller_identity.current.account_id}"
    environment_name    = "${var.environment_name}"
    project_name        = "${var.project_name}"
    container_name      = "casenotes"
    image_url           = "${var.casenotes_conf["image"]}"
    image_version       = "${var.casenotes_conf["image_version"]}"
    log_group_name      = "${local.name_prefix}-casenotes-pri-cwl"
    env_debug_log       = "${var.casenotes_conf["env_debug_log"]}"
    env_mongo_db_url    = "mongodb://mongodb.${data.terraform_remote_state.ecs_cluster.private_cluster_namespace["domain_name"]}:27017"
    env_mongo_db_name   = "${var.casenotes_conf["env_mongo_db_name"]}"
    env_pull_base_url   = "${replace(lookup(var.ansible_vars, "nomis_url", var.default_ansible_vars["nomis_url"]),"/elite2api", "/nomisapi/offenders/events/case_notes_for_delius")}"
    env_pull_note_types = "${var.casenotes_conf["env_pull_note_types"]}"
    env_push_base_url   =  "https://interface-app-internal.${local.external_domain}"
    env_poll_seconds    = "${var.casenotes_conf["env_poll_seconds"]}"
    env_slack_seconds   = "${var.casenotes_conf["env_slack_seconds"]}"
  }
}

# MongoDB task definition template
data "template_file" "mongodb_task_def_template" {
  template = "${file("templates/ecs/mongodb_task_def.tpl")}"

  vars {
    region           = "${var.region}"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"
    container_name   = "mongodb"
    image_url        = "${var.mongodb_conf["image"]}"
    image_version    = "${var.mongodb_conf["image_version"]}"
    log_group_name   = "${local.name_prefix}-cnotesdb-pri-cwl"
    volume_name      = "${local.name_prefix}-cnotesdb-pri-ebs"
  }
}
