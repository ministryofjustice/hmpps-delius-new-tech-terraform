resource "aws_cloudwatch_log_group" "search_log_group" {
  name              = "${local.name_prefix}-search-pri-cwl"
  retention_in_days = "${var.search_conf["es_log_retention_days"]}"
  tags              = "${merge(var.tags, map("Name", "${local.name_prefix}-search-pri-cwl"))}"
}

# Create log access policy to allow ES service role to create log stream and put events
resource "aws_cloudwatch_log_resource_policy" "search_log_access" {
  policy_name     = "${local.name_prefix}-search-pri-cwl"
  policy_document = "${data.template_file.cwlogs_accesspolicy_template.rendered}"
}

# Simple Cloudwatch Alarm for cluster health
# No actions defined at this time - needs enhance once focus switches to ops
# See https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/cloudwatch-alarms.html
resource "aws_cloudwatch_metric_alarm" "search_redhealth_alarm" {
  alarm_name                = "${local.name_prefix}-eshealth-red-cwa"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "ClusterStatus.red"
  namespace                 = "AWS/ES"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "At least one primary shard and its replicas are not allocated to a node"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "search_yellowhealth_alarm" {
  alarm_name                = "${local.name_prefix}-eshealth-yellow-cwa"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "ClusterStatus.yellow"
  namespace                 = "AWS/ES"
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "At least one replica shard is not allocated to a node"
  insufficient_data_actions = []
}
