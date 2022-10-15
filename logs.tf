// Create the Cloudwatch log group
module "log_group" {
  source  = "Invicton-Labs/log-group/aws"
  version = "~>0.4.0"
  log_group_config = {
    name              = "/aws/lambda/${var.edge ? "us-east-1." : ""}${var.lambda_config.function_name}"
    retention_in_days = var.cloudwatch_logs_retention_days
    kms_key_id        = var.cloudwatch_logs_kms_key_id
    tags              = var.lambda_config.tags
  }
  lambda_subscriptions     = var.logs_lambda_subscriptions
  non_lambda_subscriptions = var.logs_non_lambda_subscriptions
}
