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

variable "web_conf" {
  description = "Config map for New Tech Web Fronted ECS task"
  type        = "map"

  default = {
    image = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/new-tech-web"

    image_version = "0.2.33"
    service_port  = 9000
    cpu           = "1024"
    memory        = "512"

    # ECS Task App Autoscaling min and max thresholds
    ecs_scaling_min_capacity = 1
    ecs_scaling_max_capacity = 5

    # ECS Task App AutoScaling will kick in above avg cpu util set here
    ecs_target_cpu = "60"

    # Web env vars - defaults mirror those set in the app's application.conf file
    env_application_secret                 = ""          # APPLICATION_SECRET - no default - a value will be pulled from ssm at build time
    env_elastic_search_host                = ""          # ELASTIC_SEARCH_HOST - will be pulled from remote state of search component
    env_elastic_search_port                = 443         # ELASTIC_SEARCH_PORT
    env_elastic_search_scheme              = "https"     # ELASTIC_SEARCH_SCHEME=
    env_elastic_search_sign_requests       = "true"      # ELASTIC_SEARCH_AWS_SIGNREQUESTS
    env_custody_api_auth_username          = ""          # CUSTODY_API_USERNAME - no default - a value will be pulled from ssm at build time
    env_custody_api_auth_password          = ""          # CUSTODY_API_PASSWORD - no default - a value will be pulled from ssm at build time
    env_params_user_token_valid_duration   = "1h"        # PARAMS_USER_TOKEN_VALID_DURATION
    env_store_provider                     = "alfresco"  # STORE_PROVIDER
    env_alfresco_scheme                    = "https"     # Either https or http
    env_store_alfresco_user                = "N00"       # STORE_ALFRESCO_USER
    env_prisoner_api_provider              = "elite"     # PRISONER_API_PROVIDER
    env_base_path                          = "/newTech/" # BASE_PATH
    env_feedback_form_url                  = "https://goo.gl/forms/6HezOsoLUEDYkDgX2" # FEEDBACK_FORM_URL
    env_feedback_parom1_form_url           = "https://goo.gl/forms/tau33AGsZhYCbTpk1" # FEEDBACK_PAROM1_FORM_URL
    env_feedback_search_form_url           = "https://forms.gle/iWpkM21KtNDgzFAm7"    # FEEDBACK_SEARCH_FORM_URL
    env_feedback_offender_summary_form_url = "https://goo.gl/forms/SVgL3CuCNpvkuHxJ2" # FEEDBACK_OFFENDER_SUMMARY_FORM_URL
    env_offender_search_provider           = "elasticsearch"# OFFENDER_SEARCH_PROVIDER
    env_probation_search_base_url          = ""             # PROBATION_OFFENDER_SEARCH_URL
    env_hmpps_auth_base_url                = ""             # HMPPS_AUTH_BASE_URL
    env_nomis_api_base_url                 = ""             # NOMIS_API_BASE_URL
  }
}

variable "cloudwatch_log_retention" {
  description = "Cloudwatch logs data retention in days"
  default     = "14"
}
