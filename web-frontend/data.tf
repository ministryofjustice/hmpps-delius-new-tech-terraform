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

# Load in new tech pdf generator state
data "terraform_remote_state" "newtech_pdf" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "pdf-generator/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in new tech offender api
data "terraform_remote_state" "newtech_offenderapi" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "offender-api/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in new tech casenotes service for mongo access api
data "terraform_remote_state" "newtech_casenotes" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "case-notes/terraform.tfstate"
    region = "${var.region}"
  }
}

# Get current context for things like account id
data "aws_caller_identity" "current" {}

# Template files for New Tech Web Frontend task role and execution role definitions
data "template_file" "ecstasks_assumerole_template" {
  template = "${file("${path.module}/templates/iam/ecstasks_assumerole_policy.tpl")}"
  vars     = {}
}

data "template_file" "web_exec_policy_template" {
  template = "${file("${path.module}/templates/iam/web_exec_policy.tpl")}"

  vars = {
    region           = "${var.region}"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"
  }
}

data "template_file" "web_policy_template" {
  template = "${file("${path.module}/templates/iam/web_policy.tpl")}"

  vars = {
    domain_arn       = "${data.terraform_remote_state.newtech_search.newtech_search_config["domain_arn"]}"
  }
}

# New Tech Web Frontend task definition template
data "template_file" "web_task_def_template" {
  template = "${file("${path.module}/templates/ecs/web_task_def.tpl")}"

  vars {
    region                               = "${var.region}"
    aws_account_id                       = "${data.aws_caller_identity.current.account_id}"
    environment_name                     = "${var.environment_name}"
    project_name                         = "${var.project_name}"
    container_name                       = "newtechweb"
    image_url                            = "${var.web_conf["image"]}"
    image_version                        = "${var.web_conf["image_version"]}"
    service_port                         = "${var.web_conf["service_port"]}"
    log_group_name                       = "${aws_cloudwatch_log_group.web_log_group.name}"
    env_analytics_mongo_connection       = "${var.web_conf["env_analytics_mongo_connection"]}"
    env_application_secret               = "${var.web_conf["env_application_secret"]}"
    env_elastic_search_host              = "${data.terraform_remote_state.newtech_search.newtech_search_config["endpoint"]}"
    env_elastic_search_port              = "${var.web_conf["env_elastic_search_port"]}"
    env_elastic_search_scheme            = "${var.web_conf["env_elastic_search_scheme"]}"
    env_nomis_api_base_url               = "${lookup(var.ansible_vars, "nomis_url", var.default_ansible_vars["nomis_url"])}"
    env_offender_api_provider            = "${data.terraform_remote_state.newtech_offenderapi.newtech_offenderapi_endpoint}"
    env_params_user_token_valid_duration = "${var.web_conf["env_params_user_token_valid_duration"]}"
    env_pdf_generator_url                = "${data.terraform_remote_state.newtech_pdf.newtech_pdf_endpoint}"
    env_store_alfresco_url               = "http://alfresco.${data.terraform_remote_state.vpc.public_zone_name}/alfresco/service"
    env_store_provider                   = "${var.web_conf["env_store_provider"]}"
  }
}
