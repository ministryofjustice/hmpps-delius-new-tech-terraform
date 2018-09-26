############################################
# DEPLOYER KEY FOR PROVISIONING
############################################

resource "aws_key_pair" "environment" {
  key_name   = "${local.environment_name}"
  public_key = "${var.jenkins_public_key}"
}
