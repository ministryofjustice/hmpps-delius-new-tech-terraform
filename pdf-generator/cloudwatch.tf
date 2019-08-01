resource "aws_cloudwatch_log_group" "pdf_log_group" {
  name              = "${local.name_prefix}-pdfgen-pri-cwl"
  retention_in_days = "${var.cloudwatch_log_retention}"
  tags              = "${merge(var.tags, map("Name", "${local.name_prefix}-pdfgen-pri-cwl"))}"
}
