output "region" {
  description = "The AWS region where the resources are deployed."
  value       = local.region
}
output "iam_role_name" {
  description = "The name of the IAM role that the Lambda uses."
  value       = local.role_id
}
output "lambda" {
  description = "The `aws_lambda_function` resource that was created."
  value       = aws_lambda_function.function
}
output "log_group" {
  description = "The `aws_cloudwatch_log_group` resource that was created for the Lambda to log to."
  value       = module.log_group.log_group
}

output "complete" {
  description = "A flag for determining when everything in this module has been created."
  depends_on = [
    module.log_group.complete,
    aws_iam_role.lambda_role,
    aws_iam_role_policy.cloudwatch_write,
    aws_iam_role_policy.vpc_access,
    aws_iam_role_policy_attachment.role_policy_attachment,
    aws_lambda_function.function,
    aws_lambda_permission.allow_execution,
    aws_cloudwatch_event_rule.lambda,
    aws_cloudwatch_event_target.lambda,
    aws_lambda_permission.allow_schedule,
    aws_cloudwatch_event_target.lambda
  ]
  value = true
}

output "iam_role_arn" {
  description = "The value of the `iam_role_arn` input variable if provided, or the ARN of the newly created role if not."
  value       = module.iam_role_provided.provided ? var.iam_role_arn : aws_iam_role.lambda_role[0].arn
}
