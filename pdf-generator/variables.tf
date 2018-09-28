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

variable "pdf_generator_min_asg_size" {
  type = "string"
}

variable "pdf_generator_max_asg_size" {
  type = "string"
}

variable "pdf_generator_instance_type" {
  type = "string"
}

variable "pdf_generator_lower_cpu_trigger" {
  type = "string"
}

variable "pdf_generator_upper_cpu_trigger" {
  type = "string"
}

variable "pdf_generator_debug_log" {
  type = "string"
}

variable "vpc_cidr" {
  description = "The CIDR block assigned to the VPC"
}

variable "tags" {
  type = "map"
  description = "Default tag set"
}

variable "route53_domain_private" {
  description = "The DNS domain for all HMPPS probation services"
}
