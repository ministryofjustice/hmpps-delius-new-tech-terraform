variable "environment_name" {
  type = "string"
}

variable "short_environment_name" {
  type = "string"
}

variable "project_name" {
  description = "The project name - delius-core"
}

variable "project_name_abbreviated" {
  description = "The abbreviated project name, e.g. dat-> delius auto test"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

variable "dependencies_bucket_arn" {
  description = "S3 bucket arn for dependencies"
}

variable "tags" {
  type = "map"
}

variable "offenderpollpush_conf" {
  description = "Config map for Offender Poll/Push task"
  type        = "map"

  default = {
    image = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/new-tech-offender-pollpush"

    image_version = "0.1.10"
    cpu           = "1024"
    memory        = "512"

    # Task Def Env Vars
    env_debug_log                       = "false"
    env_index_all_offenders             = "false"
    env_ingestion_pipeline              = "pnc-pipeline"
    env_delius_api_username             = "NationalUser"
    env_elastic_search_scheme           = "https"
    env_elastic_search_port             = "443"
    env_elastic_search_aws_signrequests = "true"
    env_elastic_search_aws_servicename  = "es"
    env_all_pull_page_size              = "1000"
    env_process_page_size               = "10"
    env_poll_seconds                    = "60"
    env_sns_region                      = "eu-west-2"
  }
}

variable "cloudwatch_log_retention" {
  description = "Cloudwatch logs data retention in days"
  default     = "14"
}
