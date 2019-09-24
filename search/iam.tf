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
