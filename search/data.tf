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

# Get current context for things like account id
data "aws_caller_identity" "current" {}

data "template_file" "search_accesspolicy_template" {
  template = "${file("${path.module}/templates/es_access_policy.tpl")}"

  vars = {
    region     = "${var.region}"
    account_id = "${data.aws_caller_identity.current.account_id}"
    domain     = "${var.search_conf["es_domain"]}"
  }
}

data "template_file" "cwlogs_accesspolicy_template" {
  template = "${file("${path.module}/templates/cwlogs_access_policy.tpl")}"

  vars = {}
}
