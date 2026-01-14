data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region = var.region != null ? var.region : data.aws_region.current.region
}
