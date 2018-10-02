resource "aws_kms_key" "key" {
  description = "${var.key_name}"
  tags       = "${merge(var.tags, map("Name", var.key_name))}"
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.key_name}"
  target_key_id = "${aws_kms_key.key.key_id}"
}

