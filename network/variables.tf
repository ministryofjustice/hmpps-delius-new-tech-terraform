variable "region" {
  description = "The AWS region"
}

variable "project_name" {
  description = "The project name - delius new tech"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "az_count" {
  type = "string"
}

variable "vpc_cidr" {
  description = "The CIDR block assigned to the VPC"
}

variable "engineering_account_id" {
  description = "The ID of the engineering account"
}

variable "bastion_vpc_cidr" {
  description = "The CIDR of the VPC where the bastion server lives"
}

variable "bastion_vpc_id" {
  description = "The VPC where the bastion server lives"
}

variable "ci_vpc_cidr" {
  description = "The CIDR of the VPC where CI tooling lives"
}

variable "ci_vpc_id" {
  description = "The VPC where CI tooling lives"
}

variable "cloudwatch_log_retention" {
  description = "Number of days to retain cloudwatch logs"
}

variable "tags" {
  type = "map"
  description = "Default tag set"
}
