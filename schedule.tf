// Create a rule that runs on a schedule
resource "aws_cloudwatch_event_rule" "lambda" {
  count               = length(var.schedules)
  name_prefix         = var.lambda_config.function_name
  description         = "Schedule for the Lambda function ${var.lambda_config.function_name}"
  schedule_expression = var.schedules[count.index]
}

// Create a target for the rule (the Lambda function)
resource "aws_cloudwatch_event_target" "lambda" {
  count = length(aws_cloudwatch_event_rule.lambda)
  rule  = aws_cloudwatch_event_rule.lambda[count.index].name
  arn   = aws_lambda_function.function.arn
}

// Create a permission that allows the CloudWatch event to invoke the Lambda
resource "aws_lambda_permission" "allow_schedule" {
  count         = length(aws_cloudwatch_event_rule.lambda)
  statement_id  = "AllowExecutionFromCloudwatchEvent-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda[count.index].arn
}
