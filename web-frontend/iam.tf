# Task Execution Role for pulling the image and put'ing logs to cloudwatch
resource "aws_iam_role" "web_execute_role" {
  name               = "${local.name_prefix}-newtechwebexec-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

resource "aws_iam_role_policy" "web_execute_policy" {
  name = "${local.name_prefix}-newtechwebexec-pri-iam"
  role = "${aws_iam_role.web_execute_role.name}"

  policy = "${data.template_file.web_exec_policy_template.rendered}"
}

# Task role for the NewTech Web Frontend task to interact with AWS services, e.g. managed ES
resource "aws_iam_role" "web_task_role" {
  name               = "${local.name_prefix}-newtechweb-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

resource "aws_iam_role_policy" "web_policy" {
  name = "${local.name_prefix}-newtechweb-pri-iam"
  role = "${aws_iam_role.web_task_role.name}"

  policy = "${data.template_file.web_policy_template.rendered}"
}