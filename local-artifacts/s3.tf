
resource "aws_s3_bucket" "bucket" {
  bucket          = "${var.environment_identifier}-artifacts"
  acl             = ""
  tags            = "${merge(var.tags, map("Name", "${var.environment_identifier}-artifacts"))}"
}

