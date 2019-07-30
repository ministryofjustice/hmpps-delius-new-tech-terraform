# Task Execution Role for pulling the image and put'ing logs to cloudwatch
resource "aws_iam_role" "pdf_execute_role" {
  name               = "${local.name_prefix}-pdfgenexec-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}

resource "aws_iam_role_policy" "pdf_execute_policy" {
  name = "${local.name_prefix}-pdfgen-pri-iam"
  role = "${aws_iam_role.pdf_execute_role.name}"

  policy = "${data.template_file.pdf_policy_template.rendered}"
}

# Task role for the pdf generator task to interact with AWS services
# No policy needed atm, but could be down the line if move to documentdb/dynamodb
resource "aws_iam_role" "pdf_task_role" {
  name               = "${local.name_prefix}-pdfgen-pri-iam"
  assume_role_policy = "${data.template_file.ecstasks_assumerole_template.rendered}"
}
