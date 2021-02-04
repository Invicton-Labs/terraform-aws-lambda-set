terraform {
  // Enable the optional attributes experiment
  experiments = [module_variable_optional_attrs]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}