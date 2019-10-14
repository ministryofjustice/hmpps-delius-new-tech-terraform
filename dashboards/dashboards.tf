resource "aws_cloudwatch_dashboard" "newtech" {
  dashboard_name = "newtech"
  dashboard_body = "${data.template_file.newtech_dashboard.rendered}"
  count          = "${var.dashboards_enabled == "true" ? 1:0}"
}
