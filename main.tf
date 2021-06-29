terraform {
  required_version = ">= 1.0.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.47"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
