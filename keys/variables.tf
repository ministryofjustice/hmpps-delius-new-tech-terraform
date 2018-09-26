variable "region" {
  description = "The AWS region"
}

variable "project_name" {
  description = "The project name - delius new tech"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "jenkins_public_key" {
  description = "The public key used for ssh communication from jenkins slaves"
}

variable "tags" {
  type = "map"
  description = "Default tag set"
}

