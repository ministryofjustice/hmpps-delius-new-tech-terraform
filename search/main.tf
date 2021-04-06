terraform {
  # # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.23.0"
}

provider "template" {
  version = "~>2.1.2"
}
