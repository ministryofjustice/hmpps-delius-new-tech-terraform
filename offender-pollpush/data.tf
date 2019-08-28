# Load in VPC state data for subnet placement
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in VPC security groups to reference db sgs
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in Delius Core security Groups for db and ldap access
data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/security-groups/terraform.tfstate"
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

# Load in NEW TECH ES CLUSTER STATE for SG rules
data "terraform_remote_state" "newtech_search" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "search/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in NEW TECH Offender API state for SG rules
data "terraform_remote_state" "newtech_offapi" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "offender-api/terraform.tfstate"
    region = "${var.region}"
  }
}

# Get current context for things like account id
data "aws_caller_identity" "current" {}

# Template files for offenderpollpush task role and execution role definitions
data "template_file" "ecstasks_assumerole_template" {
  template = "${file("${path.module}/templates/iam/ecstasks_assumerole_policy.tpl")}"
  vars     = {}
}

data "template_file" "offenderpollpush_exec_policy_template" {
  template = "${file("${path.module}/templates/iam/offenderpollpush_exec_policy.tpl")}"

  vars = {
    region           = "${var.region}"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"
  }
}

data "template_file" "offenderpollpush_policy_template" {
  template = "${file("${path.module}/templates/iam/offenderpollpush_policy.tpl")}"

  vars = {
    domain_arn     = "${data.terraform_remote_state.newtech_search.newtech_search_config["domain_arn"]}"
  }
}

# Offender API task definition template
data "template_file" "offenderpollpush_task_def_template" {
  template = "${file("templates/ecs/offenderpollpush_task_def.tpl")}"

  vars {
    region                     = "${var.region}"
    aws_account_id             = "${data.aws_caller_identity.current.account_id}"
    environment_name           = "${var.environment_name}"
    project_name               = "${var.project_name}"
    container_name             = "offenderpollpush"
    image_url                  = "${var.offenderpollpush_conf["image"]}"
    image_version              = "${var.offenderpollpush_conf["image_version"]}"
    log_group_name             = "${aws_cloudwatch_log_group.offenderpollpush_log_group.name}"
    env_debug_log              = "${var.offenderpollpush_conf["env_debug_log"]}"
    env_index_all_offenders    = "${var.offenderpollpush_conf["env_index_all_offenders"]}"
    env_ingestion_pipeline     = "${var.offenderpollpush_conf["env_ingestion_pipeline"]}"
    env_delius_api_base_url    = "${data.terraform_remote_state.newtech_offapi.newtech_offenderapi_endpoint}"
    env_delius_api_username    = "${var.offenderpollpush_conf["env_delius_api_username"]}"
    env_elastic_search_scheme  = "${var.offenderpollpush_conf["env_elastic_search_scheme"]}"
    env_elastic_search_host    = "${data.terraform_remote_state.newtech_search.newtech_search_config["endpoint"]}"
    env_elastic_search_cluster = "${data.terraform_remote_state.newtech_search.newtech_search_config["domain_name"]}"
    env_elastic_search_port    = "${var.offenderpollpush_conf["env_elastic_search_port"]}"
    env_all_pull_page_size     = "${var.offenderpollpush_conf["env_all_pull_page_size"]}"
    env_process_page_size      = "${var.offenderpollpush_conf["env_process_page_size"]}"
    env_poll_seconds           = "${var.offenderpollpush_conf["env_poll_seconds"]}"
  }
}
