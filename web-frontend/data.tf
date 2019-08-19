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

# Load in new tech ES search state
data "terraform_remote_state" "newtech_search" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "search/terraform.tfstate"
    region = "${var.region}"
  }
}

# Template files for New Tech Web Frontend task role and execution role definitions
data "template_file" "ecstasks_assumerole_template" {
  template = "${file("${path.module}/templates/iam/ecstasks_assumerole_policy.tpl")}"
  vars     = {}
}

data "template_file" "web_policy_template" {
  template = "${file("${path.module}/templates/iam/web_exec_policy.tpl")}"

  vars = {
    region           = "${var.region}"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"
  }
}

# New Tech Web Frontend task definition template
data "template_file" "web_task_def_template" {
  template = "${file("templates/ecs/web_task_def.tpl")}"

  vars {
    region                         = "${var.region}"
    aws_account_id                 = "${data.aws_caller_identity.current.account_id}"
    environment_name               = "${var.environment_name}"
    project_name                   = "${var.project_name}"
    container_name                 = "newtech-web"
    image_url                      = "${var.webconf["image"]}"
    image_version                  = "${var.web_conf["image_version"]}"
    env_service_port               = "${var.web_conf["env_service_port"]}"
    log_group_name                 = "${aws_cloudwatch_log_group.web_log_group.name}"
    env_debug                      = "${var.offenderapi_conf["env_debug"]}"
  }
}