locals {
  # Handle mixed environments project name
  short_project_name = "${replace(var.project_name, "delius-core", "delius")}"
  name_prefix        = "${var.project_name_abbreviated}-${local.short_project_name}"

  private_subnet_ids = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}",
  ]

  public_subnet_ids = [
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az3}",
  ]

  public_zone_id  = "${data.terraform_remote_state.vpc.public_zone_id}"
  external_domain = "${data.terraform_remote_state.vpc.public_zone_name}"

  public_certificate_arn = "${data.aws_acm_certificate.cert.arn}"
}
