# The source bundle

data "archive_file" "source-bundle" {
  type        = "zip"
  source_dir = "${path.module}/source-bundle"
  output_path = "source-bundle.zip"
}

data "aws_kms_key" "master" {
  key_id = "alias/master"
}

locals {
  application_config_name = "Dockerrun.aws.json.zip"
}

data "aws_s3_bucket" "bucket" {
  bucket          = "${var.environment_identifier}-artifacts"
}

resource "aws_s3_bucket_object" "object" {
  bucket = "${data.aws_s3_bucket.bucket.id}"
  key    = "pdf-generator/${local.application_config_name}"
  source = "${data.archive_file.source-bundle.output_path}"
  etag   = "${md5(file("${data.archive_file.source-bundle.output_path}"))}"
}

resource "aws_elastic_beanstalk_application_version" "latest" {
  name        = "latest"
  application = "${local.application_name}"
  description = "Version latest of app ${local.application_name}"
  bucket      = "${data.aws_s3_bucket.bucket.id}"
  key         = "pdf-generator/${local.application_config_name}"
  depends_on = ["aws_s3_bucket_object.object"]
}
