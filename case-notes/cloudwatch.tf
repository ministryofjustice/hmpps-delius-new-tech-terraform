resource "aws_cloudwatch_log_group" "casenotes_log_group" {
  name              = "${local.name_prefix}-casenotes-pri-cwl"
  retention_in_days = "${var.log_retention}"
  tags              = "${merge(var.tags, map("Name", "${local.name_prefix}-casenotes-pri-cwl"))}"
}

resource "aws_cloudwatch_log_group" "cnotesdb_log_group" {
  name              = "${local.name_prefix}-cnotesdb-pri-cwl"
  retention_in_days = "${var.log_retention}"
  tags              = "${merge(var.tags, map("Name", "${local.name_prefix}-cnotesdb-pri-cwl"))}"
}
