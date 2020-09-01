resource "aws_iam_service_linked_role" "search" {
  aws_service_name = "es.amazonaws.com"
}

# IAM Role for Cognito auth'd users to assume when logged into Kibana
# ES Permissions for the role are assigned in the ES access policy document
resource "aws_iam_role" "search_kibana_role" {
  count              = "${local.role_policy_attach_search}"
  name               = "${local.name_prefix}-kibanauser-pri-iam"
  assume_role_policy = "${data.template_file.search_kibana_assume_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "search_kibana_cognito_access" {
  count      = "${local.role_policy_attach_search}"
  role       = "${aws_iam_role.search_kibana_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}

resource "aws_iam_role_policy_attachment" "search_kibana_es_access" {
  count      = "${local.role_policy_attach_search}"
  role       = "${aws_iam_role.search_kibana_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}

#--------------------------------------------------------------------------------
# Cloud Platform - Probation in Court Services access to Newtech Elasticsearch
# https://dsdmoj.atlassian.net/wiki/spaces/DAM/pages/1850507436/Probation+in+Court+services+access+NewTech+ElasticSearch+cluster
#--------------------------------------------------------------------------------

data "template_file" "cloudplatform_offender_search_assumerole_policy_template" {
  template = "${file("${path.module}/templates/iam/cloudplatform_offender_search_assume_role.tpl")}"
  vars = {
    environment_name                        = "${var.environment_name}"
    cloudplatform_account_id                = "${lookup(var.aws_account_ids, "cloud-platform")}"
    cloudplatform_offender_search_role_name = "${var.cloudplatform_offender_search_role_name}"
    delius_iam_account_id                   = "${lookup(var.aws_account_ids, "hmpps-probation")}"
  }
}

resource "aws_iam_role" "cloudplatform_offender_search_role" {
  count              = "${local.role_policy_attach_search}"
  name               = "cp-offender-search-service-role-${var.environment_name}"
  description        = "IAM role for cloudplatform Offender Search access to Delius"
  assume_role_policy = "${data.template_file.cloudplatform_offender_search_assumerole_policy_template.rendered}"
}

data "template_file" "cloudplatform_offender_search_policy_template" {
  template = "${file("${path.module}/templates/cloudplatform_offender_search_policy.tpl")}"

  vars = {
    region      = "${var.region}"
    account_id  = "${data.aws_caller_identity.current.account_id}"
    domain      = "${var.search_conf["es_domain"]}"
  }
}

resource "aws_iam_role_policy" "cloudplatform_offender_search_role_policy" {
  count  = "${local.role_policy_attach_search}"
  name   = "cp-offender-search-service-role-policy"
  role   = "${aws_iam_role.cloudplatform_offender_search_role.name}"
  policy = "${data.template_file.cloudplatform_offender_search_policy_template.rendered}"
}
