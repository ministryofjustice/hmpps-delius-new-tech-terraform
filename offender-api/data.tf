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

# Load in LDAP (apacheds) state for ldap connectivity details
data "terraform_remote_state" "delius_ldap" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = "${var.region}"
  }
}

# Load in Delius Core ldap state for LB FQDN

# Get current context for things like account id
data "aws_caller_identity" "current" {}

# Template files for offenderapi task role and execution role definitions
data "template_file" "ecstasks_assumerole_template" {
  template = "${file("${path.module}/templates/iam/ecstasks_assumerole_policy.tpl")}"
  vars     = {}
}

data "template_file" "offenderapi_policy_template" {
  template = "${file("${path.module}/templates/iam/offenderapi_exec_policy.tpl")}"

  vars = {
    region           = "${var.region}"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"
  }
}

# Offender API task definition template
data "template_file" "offenderapi_task_def_template" {
  template = "${file("templates/ecs/offenderapi_task_def.tpl")}"

  vars {
    region                         = "${var.region}"
    aws_account_id                 = "${data.aws_caller_identity.current.account_id}"
    environment_name               = "${var.environment_name}"
    project_name                   = "${var.project_name}"
    container_name                 = "offenderapi"
    image_url                      = "${var.offenderapi_conf["image"]}"
    image_version                  = "${var.offenderapi_conf["image_version"]}"
    env_service_port               = "${var.offenderapi_conf["env_service_port"]}"
    log_group_name                 = "${aws_cloudwatch_log_group.offenderapi_log_group.name}"
    env_oracledb_endpoint          = ""
    env_public_zone                = "${data.terraform_remote_state.vpc.public_zone_name}"
    env_ldap_endpoint              = "${data.terraform_remote_state.delius_ldap.private_fqdn_ldap_elb}"
    env_ldap_port                  = "${data.terraform_remote_state.delius_ldap.ldap_port}"
    env_spring_profiles_active     = "${var.offenderapi_conf["env_spring_profiles_active"]}"
    env_spring_datasource_username = "${var.offenderapi_conf["env_spring_datasource_username"]}"
    env_spring_ldap_username       = "${data.terraform_remote_state.delius_ldap.ldap_bind_user}"
    env_oracledb_servicename       = "${var.offenderapi_conf["env_oracledb_servicename"]}"
    env_debug                      = "${var.offenderapi_conf["env_debug"]}"
    env_alfresco_baseurl           = "https://alfresco.${data.terraform_remote_state.vpc.public_zone_name}/alfresco/s/noms-spg"
    env_push_base_url              = "https://interface-app-internal.${local.external_domain}/api"
    env_jwt_public_key             = "${var.offenderapi_conf["env_jwt_public_key"]}"
    env_delius_ldap_users_base    =  "${data.terraform_remote_state.delius_ldap.ldap_base_users}"
    env_features_noms_update_custody = "${var.offenderapi_conf["env_features_noms_update_custody"]}"
    env_features_noms_update_booking_number = "${var.offenderapi_conf["env_features_noms_update_booking_number"]}"
    env_features_noms_update_keydates = "${var.offenderapi_conf["env_features_noms_update_keydates"]}"
  }
}

data "aws_acm_certificate" "cert" {
  domain      = "${data.terraform_remote_state.vpc.public_ssl_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
