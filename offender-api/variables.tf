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

variable "offenderapi_conf" {
  description = "Config map for Offender API task"
  type        = "map"

  default = {
    image         = "quay.io/hmpps/community-api"
    image_version = "2020-09-17.2015.87740b9"
    cpu           = "1024"
    memory        = "512"

    # ECS Task App Autoscaling min and max thresholds
    ecs_scaling_min_capacity = 1
    ecs_scaling_max_capacity = 5

    # ECS Task App AutoScaling will kick in above avg cpu util set here
    ecs_target_cpu = "60"

    # Enable/disable public-facing load balancer for exposing Swagger docs (see alb-public.tf)
    enable_public_lb = false

    # Task Def Env Vars
    env_service_port               = 8080
    env_oracledb_servicename       = "DNDA_TAF"
    env_spring_profiles_active     = "oracle"
    env_spring_datasource_username = "delius_pool"
    env_debug                      = "false"
    env_oauth2_jwt_jwk_set_uri     = "should_be_overridden"
    env_features_noms_update_custody = "false"
    env_features_noms_update_booking_number = "false"
    env_features_noms_update_keydates = "false"
    env_features_noms_update_noms_number = "false"
  }
}

variable "cloudwatch_log_retention" {
  description = "Cloudwatch logs data retention in days"
  default     = "14"
}

variable "offender_api_allowed_cidrs" {
  description = "Allowed ingress CIDRs for offender api (aka community api)"
  type        = "list"
  default     = []
}

variable "offender_api_allowed_secure_cidrs" {
  description = "Allowed ingress CIDRs for secure version of offender api (aka community api)"
  type        = "list"
  default     = []
}
