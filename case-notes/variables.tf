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

variable "casenotes_conf" {
  description = "Config map for case notes poll/push task"
  type        = "map"

  default = {
    image         = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/new-tech-casenotes"
    image_version = "0.1.08"
    cpu           = "1024"
    memory        = "512"

    # Task Def Env Vars
    env_debug_log     = "false"
    env_mongo_db_name = "pollpush"

    # NOMIS Endpoint
    env_pull_base_url   = "http://localhost:8080/nomisapi/offenders/events/case_notes"
    env_pull_note_types = ""

    # NDelius Endpoint
    env_push_base_url = "http://localhost:8080/delius"
    env_poll_seconds  = "60"
    env_slack_seconds = "0"
  }
}

variable "mongodb_conf" {
  description = "Config map for case notes MongoDB task"
  type        = "map"

  default = {
    image         = "docker.io/mongo"
    image_version = "4.0.10"
    cpu           = "512"
    memory        = "512"
  }
}

variable "log_retention" {
  description = "Cloudwatch logs data retention in days"
  default     = "14"
}

variable "ansible_vars" {
  default = {}
  type    = "map"
}

variable "default_ansible_vars" {
  default = {}
  type    = "map"
}