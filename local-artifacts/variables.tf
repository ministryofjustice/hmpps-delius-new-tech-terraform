variable "region" {
  description = "The AWS region"
}

variable "project_name" {
  description = "The project name - delius new tech"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "environment_identifier" {
  description = "The environment identifier"
}

variable "tags" {
  type = "map"
  description = "Default tag set"
}
