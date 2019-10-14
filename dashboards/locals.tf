locals {
  # Handle mixed environments project name
  short_project_name = "${replace(var.project_name, "delius-core", "delius")}"
  name_prefix        = "${var.project_name_abbreviated}-${local.short_project_name}"
}
