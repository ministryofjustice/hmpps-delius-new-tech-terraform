# Task Execution Role for pulling the image and put'ing logs to cloudwatch
resource "aws_iam_role" "casenotes_execute_role" {
  name               = "${local.name_prefix}-cnotesexec-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

resource "aws_iam_role_policy" "casenotes_execute_policy" {
  name = "${local.name_prefix}-cnotesexec-pri-iam"
  role = "${aws_iam_role.casenotes_execute_role.name}"

  policy = "${data.template_file.cnotesexec_policy_template.rendered}"
}

# Task role for the casenotes task to interact with AWS services
# No policy needed atm, but could be down the line if move to documentdb/dynamodb
resource "aws_iam_role" "casenotes_task_role" {
  name               = "${local.name_prefix}-casenotes-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

# Task role for the mongodb task itself to interact with AWS services
# No policy needed atm, but could be if, e.g. backups to s3 needed
resource "aws_iam_role" "mongodb_task_role" {
  name               = "${local.name_prefix}-cnotesdb-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}
