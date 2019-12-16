# Task Execution Role for pulling the image and put'ing logs to cloudwatch
resource "aws_iam_role" "offendersearch_execute_role" {
  name               = "${local.name_prefix}-offendersearchexec-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

resource "aws_iam_role_policy" "offendersearch_execute_policy" {
  name = "${local.name_prefix}-offendersearchexec-pri-iam"
  role = "${aws_iam_role.offendersearch_execute_role.name}"

  policy = "${data.template_file.offendersearch_exec_policy_template.rendered}"
}

# Task role for the NewTech Web Frontend task to interact with AWS services, e.g. managed ES
resource "aws_iam_role" "offendersearch_task_role" {
  name               = "${local.name_prefix}-offendersearch-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

resource "aws_iam_role_policy" "offendersearch_policy" {
  name = "${local.name_prefix}-offendersearch-pri-iam"
  role = "${aws_iam_role.offendersearch_task_role.name}"

  policy = "${data.template_file.offendersearch_policy_template.rendered}"
}
