variable "region" {
  description = "The AWS region"
}

variable "project_name" {
  description = "The project name - delius new tech"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "tags" {
  type = "map"
  description = "Default tag set"
}

variable "whitelist_cidrs" {
  type = "list"
  description = "Permitted ingress from the internet"
}

variable "ci_vpc_cidr" {
  description = "The CIDR of the CI tooling"
}

variable "bastion_vpc_cidr" {
  description = "The CIDR of the bastion"
}

variable "world_access" {
  description = "Whether the UI can be accessed from any IP address"
}

