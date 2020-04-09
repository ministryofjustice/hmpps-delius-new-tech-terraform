resource "aws_iam_service_linked_role" "search" {
  aws_service_name = "es.amazonaws.com"
}

# IAM Role for Cognito auth'd users to assume when logged into Kibana
# ES Permissions for the role are assigned in the ES access policy document
resource "aws_iam_role" "search_kibana_role" {
  name               = "${local.name_prefix}-kibanauser-pri-iam"
  assume_role_policy = "${data.template_file.search_kibana_assume_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "search_kibana_cognito_access" {
  role     = "${aws_iam_role.search_kibana_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}

resource "aws_iam_role_policy_attachment" "search_kibana_es_access" {
  role      = "${aws_iam_role.search_kibana_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}


#----------------------------------------------
# Cloud Platform - Probation in Court Services access to Newtech Elasticsearch
# https://dsdmoj.atlassian.net/wiki/spaces/DAM/pages/1850507436/Probation+in+Court+services+access+NewTech+ElasticSearch+cluster
#----------------------------------------------

data "template_file" "cloudplatform_pcs_search_assumerole_policy_template" {
  template = "${file("${path.module}/templates/iam/search_cloudplatform_pcs_assume_role.tpl")}"
}

resource "aws_iam_role" "cloudplatform_pcs_search_role" {
  name               = "remote-pcs-newtech-elasticsearch-service-role"
  assume_role_policy = "${data.template_file.cloudplatform_pcs_search_assumerole_policy_template.rendered}"
}

data "template_file" "cloudplatform_pcs_search_policy_template" {
  template = "${file("${path.module}/templates/cloudplatform_pcs_policy.tpl")}"

  vars = {
    region      = "${var.region}"
    account_id  = "${data.aws_caller_identity.current.account_id}"
    domain      = "${var.search_conf["es_domain"]}"
  }

}

resource "aws_iam_role_policy" "cloudplatform_pcs_search_role_policy" {
  name = "remote-pcs-newtech-elasticsearch-service-role-policy"
  role = "${aws_iam_role.cloudplatform_pcs_search_role.name}"
  policy = "${data.template_file.cloudplatform_pcs_search_policy_template.rendered}"
}
