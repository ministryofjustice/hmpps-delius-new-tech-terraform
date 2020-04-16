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

variable aws_account_ids {
  description = "List of all delius application environment AWS account IDs which will consume the centralised ECR repos - will be pulled from common env_config tfvars"
  type        = "map"
}

variable cloudplatform_data {
  description = "List of Cloudplatform reference data - will be pulled from common env_config tfvars"
  type        = "map"
}

variable "search_conf" {
  description = "Config map for New Tech ElasticSearch service"
  type        = "map"

  default = {
    es_domain  = "newtech-search"
    es_version = "6.7"

    # Cluster config
    # Data node count
    es_instance_count = 1

    # See the following for restrictions around instance types
    # https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-supported-instance-types.html
    es_instance_type = "m5.large.elasticsearch"

    es_dedicated_master_enabled = false
    es_dedicated_master_count   = 0
    es_dedicated_master_type    = ""
    es_zone_aware_enabled       = false

    # Number of AZs and Subnets is calculated based on es_instance_count value

    # Encryption Options
    es_internode_encryption = true
    # Encrypt at rest only valid if ebs enabled below
    es_ebs_encrypted = true
    # EBS Options
    es_ebs_enabled = true
    es_ebs_type    = "gp2"
    es_ebs_size    = 20
    
    es_snapshot_hour  = 01
    # Logging
    es_logging_enabled = true
    # Valid values: INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS, ES_APPLICATION_LOGS
    es_log_type           = "ES_APPLICATION_LOGS"
    es_log_retention_days = 14
    # Authentication
    auth_enabled = true
  }
}

variable "search_advanced_cluster_conf" {
  description = "Advanced ElasticSearch config values"
  type        = "map"

  default = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
}

variable "search_cognito_conf" {
  description = "Cognito config for kibana auth"
  type        = "map"

  default = {
    # Password policy parameters
    password_min_length = 16
    password_uppercase  = true
    password_lowercase  = true
    password_numbers    = true
    password_symbols    = true

    # Admin only to create users. If false, users can sign up themselves
    admin_only_create = true

    # Optional email attribute and associated settings
    email_required           = false
    auto_verified_attributes = "email"
  }
}
