data "template_file" "newtech_dashboard" {
  template = "${file("${path.module}/templates/dashboards/newtech.tpl")}"

  vars {
    region = "${var.region}"
    name_prefix = "${local.name_prefix}"
  }
}
