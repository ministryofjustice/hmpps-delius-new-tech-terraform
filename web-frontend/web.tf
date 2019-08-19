resource "random_string" "web_app_secret" {
  length = 16
  special = true
}

resource "aws_ssm_parameter" "web_app_secret_param" {
    # TODO - interpolate vars
  name  = "${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password"
  type  = "SecureString"
  value = "random_string.web_app_secret.result"
}