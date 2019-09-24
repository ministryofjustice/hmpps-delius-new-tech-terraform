# SG for ElasticSearch VPC Endpoint
# Ingress rules will be added in the new tech service components
resource "aws_security_group" "search_sg" {
  name        = "${local.name_prefix}-search-pri-sg"
  description = "New Tech ElasticSearch Security Group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
    tags = "${
      merge(
          var.tags, 
          map("Name", "${local.name_prefix}-search-pri-ecs")
          )
        }"
}

resource "aws_security_group_rule" "search_ingress_bastion" {
  security_group_id = "${aws_security_group.search_sg.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "ES and Kibana ingress via bastion"
}

resource "aws_elasticsearch_domain" "search_domain" {
  domain_name = "${var.environment_name == "delius-core-sandpit"  ? local.sandpit_domain : var.search_conf["es_domain"]}"
  elasticsearch_version = "${var.search_conf["es_version"]}"

  vpc_options {
    subnet_ids = [
      "${local.es_subnets}",
    ]

    security_group_ids = ["${aws_security_group.search_sg.id}"]
  }

  cluster_config {
    instance_count           = "${var.search_conf["es_instance_count"]}"
    instance_type            = "${var.search_conf["es_instance_type"]}"
    dedicated_master_enabled = "${var.search_conf["es_dedicated_master_enabled"]}"
    dedicated_master_count   = "${var.search_conf["es_dedicated_master_count"]}"
    dedicated_master_type    = "${var.search_conf["es_dedicated_master_type"]}"
    zone_awareness_enabled   = "${var.search_conf["es_instance_count"] > 1 ? true : false}"

    zone_awareness_config {
      # Number of AZs must be either 2 or 3 and equal to subnet count when multi az / zone awareness is enabled
      availability_zone_count = "${var.search_conf["es_instance_count"] <= 2 ? 2 : 3}"
    }
  }

  ebs_options {
    ebs_enabled = "${var.search_conf["es_ebs_enabled"]}"
    volume_type = "${var.search_conf["es_ebs_type"]}"
    volume_size = "${var.search_conf["es_ebs_size"]}"
  }

  encrypt_at_rest {
    enabled = "${var.search_conf["es_ebs_encrypted"]}"
  }

  node_to_node_encryption {
    enabled = "${var.search_conf["es_internode_encryption"]}"
  }

  cognito_options {
    enabled          = "${var.search_conf["auth_enabled"]}"
    user_pool_id     = "${aws_cognito_user_pool.search_user_pool.id}"
    identity_pool_id = "${aws_cognito_identity_pool.search_identity_pool.id}"
    role_arn         = "${aws_iam_role.search_kibana_role.arn}"
  }

  advanced_options = "${var.search_advanced_cluster_conf}"

  access_policies = "${data.template_file.search_accesspolicy_template.rendered}"

  snapshot_options {
    automated_snapshot_start_hour = "${var.search_conf["es_snapshot_hour"]}"
  }

  log_publishing_options {
    enabled                  = "${var.search_conf["es_logging_enabled"]}"
    cloudwatch_log_group_arn = "${aws_cloudwatch_log_group.search_log_group.arn}"
    log_type                 = "${var.search_conf["es_log_type"]}"
  }

  tags = "${
      merge(
          var.tags, 
          map("Name", "${local.name_prefix}-search-pri-ecs"),
          map("Domain", "${var.search_conf["es_domain"]}")
          )
        }"

  # Explicitly declare dependencies - TF doesn't graph these well enough
  depends_on = [
    "aws_iam_service_linked_role.search",
    "aws_iam_role.search_kibana_role",
    "aws_cloudwatch_log_resource_policy.search_log_access",
  ]

  # Workaround for issue always applying update when none needed on single instance domains
  # Given a cluster multi az setup can't be updated after initial creation, this should be safe
  lifecycle {
    ignore_changes = [
      "cluster_config.0.zone_awareness_config",
    ]
  }
}

# Value must be updated when administering the webops kibana user in cognito
# This is just a placeholder to store the secure password
resource "aws_ssm_parameter" "kibana_webops_password" {
  name  = "${local.name_prefix}-kibana-pri-ssm"
  type  = "SecureString"
  value = "null"
}