data "template_file" "newtech_dashboard" {
  template = "${file("${path.module}/templates/dashboards/newtech.tpl")}"

  vars {
    name_prefix = "${local.name_prefix}"
  }
}
