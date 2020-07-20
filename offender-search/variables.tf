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

variable "ansible_vars" {
  default = {}
  type    = "map"
}

variable "default_ansible_vars" {
  default = {}
  type    = "map"
}

variable "offendersearch_conf" {
  description = "Config map for Offender Search Servive ECS task"
  type        = "map"

  default = {
    image         = "quay.io/hmpps/offender-search"
    image_version = "2020-07-17.442.bd5fe1e"
    service_port  = 8080
    cpu           = "1024"
    memory        = "2048"

    # ECS Task App Autoscaling min and max thresholds
    ecs_scaling_min_capacity = 1
    ecs_scaling_max_capacity = 5

    # ECS Task App AutoScaling will kick in above avg cpu util set here
    ecs_target_cpu = "60"

    # Offender search service env vars - defaults mirror those set in the app's application.yaml file
    env_elastic_search_host              = ""          # ELASTICSEARCH_HOST - will be pulled from remote state of search component
    env_elastic_search_port              = 443         # ELASTICSEARCH_PORT
    env_elastic_search_scheme            = "https"     # ELASTICSEARCH_SCHEME=
    env_elastic_search_sign_requests     = "true"      # ELASTICSEARCH_AWS_SIGNREQUESTS
  }
}

variable "cloudwatch_log_retention" {
  description = "Cloudwatch logs data retention in days"
  default     = "14"
}

variable "offender_search_allowed_secure_cidrs" {
  description = "Allowed ingress CIDRs for secure version of offender search"
  type        = "list"
  default     = []
}
