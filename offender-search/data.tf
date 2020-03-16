# Load in VPC state data for subnet placement
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in VPC security groups
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

# Load in Delius Core weblogic for web service target group
data "terraform_remote_state" "delius_core_ndelius" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ndelius/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "delius_core_interface" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/interface/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "delius_core_spg" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/spg/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "delius_core_ldap" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ldap/terraform.tfstate"
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

# Load in new tech ES search state
data "terraform_remote_state" "newtech_search" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "search/terraform.tfstate"
    region = "${var.region}"
  }
}


# Get current context for things like account id
data "aws_caller_identity" "current" {}

# Template files for Offender Search task role and execution role definitions
data "template_file" "ecstasks_assumerole_template" {
  template = "${file("${path.module}/templates/iam/ecstasks_assumerole_policy.tpl")}"
  vars     = {
    env_oauth2_jwt_jwk_set_uri = "${var.offendersearch_conf["env_oauth2_jwt_jwk_set_uri"]}"
  }
}

data "template_file" "offendersearch_exec_policy_template" {
  template = "${file("${path.module}/templates/iam/offendersearch_exec_policy.tpl")}"

  vars = {
    region           = "${var.region}"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"
  }
}

data "template_file" "offendersearch_policy_template" {
  template = "${file("${path.module}/templates/iam/offendersearch_policy.tpl")}"

  vars = {
    domain_arn = "${data.terraform_remote_state.newtech_search.newtech_search_config["domain_arn"]}"
  }
}

# Offender Search task definition template
data "template_file" "offendersearch_task_def_template" {
  template = "${file("${path.module}/templates/ecs/offendersearch_task_def.tpl")}"

  vars {
    region                               = "${var.region}"
    aws_account_id                       = "${data.aws_caller_identity.current.account_id}"
    environment_name                     = "${var.environment_name}"
    project_name                         = "${var.project_name}"
    container_name                       = "offendersearch"
    image_url                            = "${var.offendersearch_conf["image"]}"
    image_version                        = "${var.offendersearch_conf["image_version"]}"
    service_port                         = "${var.offendersearch_conf["service_port"]}"
    log_group_name                       = "${aws_cloudwatch_log_group.offendersearch_log_group.name}"
    env_elastic_search_host              = "${data.terraform_remote_state.newtech_search.newtech_search_config["endpoint"]}"
    env_elastic_search_port              = "${var.offendersearch_conf["env_elastic_search_port"]}"
    env_elastic_search_scheme            = "${var.offendersearch_conf["env_elastic_search_scheme"]}"
    env_elastic_search_sign_requests     = "${var.offendersearch_conf["env_elastic_search_sign_requests"]}"
    env_jwt_public_key                   = "${var.offendersearch_conf["env_jwt_public_key"]}"
  }
}

data "aws_acm_certificate" "cert" {
  domain      = "${data.terraform_remote_state.vpc.public_ssl_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}