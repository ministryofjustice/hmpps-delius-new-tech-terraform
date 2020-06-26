locals {
  # Handle mixed environments project name
  short_project_name = "${replace(var.project_name, "delius-core", "delius")}"
  name_prefix        = "${var.project_name_abbreviated}-${local.short_project_name}"

  # Handle ES config for single instance or multiple instance deployments
  es_single_instance_subnet_id = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
  ]

  private_subnet_ids = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}",
  ]

  # ES Subnets needs to match number of of instances upto a max value of 3 (max no of AZs in a region)
  es_subnet_count = "${var.search_conf["es_instance_count"] >= 3 ? 3 : var.search_conf["es_instance_count"]}"

  # List of ES subnets
  es_subnets = [
    "${null_resource.subnet_list.*.triggers.subnet}",
  ]

  # Handle sandpit/dev shared env
  sandpit_domain = "sandpit-${var.search_conf["es_domain"]}"

  cloudplatform_cidr_range = "${var.cloudplatform_data["cidr_range"]}"


  cloudplatform_pcs_search_role_name = "cp-offender-search-service-role-${var.environment_name}"

  cloudplatform_offender_search_role_envs = {
    delius-core-dev  = "1"
    delius-stage     = "1"
    delius-pre-prod  = "1"
    delius-prod      = "1"
  }

  role_cloudplatform_offender_search_role_envs = "${lookup(local.cloudplatform_offender_search_role_envs, "${var.environment_name}" , 0) }"
  

}

# Build list of subnets from private subnet ids equal to number of ES subnets required
resource "null_resource" "subnet_list" {
  count = "${local.es_subnet_count}"

  triggers {
    subnet = "${local.private_subnet_ids[count.index]}"
  }
}
