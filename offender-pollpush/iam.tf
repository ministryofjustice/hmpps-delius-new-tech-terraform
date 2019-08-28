# Task Execution Role for pulling the image and put'ing logs to cloudwatch
resource "aws_iam_role" "offenderpollpush_execute_role" {
  name               = "${local.name_prefix}-offpollexec-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

resource "aws_iam_role_policy" "offenderpollpush_execute_policy" {
  name = "${local.name_prefix}-offpollexec-pri-iam"
  role = "${aws_iam_role.offenderpollpush_execute_role.name}"

  policy = "${data.template_file.offenderpollpush_exec_policy_template.rendered}"
}

# Task role for the offender api task to interact with AWS services incl ES
resource "aws_iam_role" "offenderpollpush_task_role" {
  name               = "${local.name_prefix}-offpoll-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

resource "aws_iam_role_policy" "offenderpollpush_policy" {
  name = "${local.name_prefix}-offpoll-pri-iam"
  role = "${aws_iam_role.offenderpollpush_task_role.name}"

  policy = "${data.template_file.offenderpollpush_policy_template.rendered}"
}