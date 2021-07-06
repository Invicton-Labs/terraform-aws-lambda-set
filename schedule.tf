// Create a rule that runs on a schedule
resource "aws_cloudwatch_event_rule" "lambda" {
  for_each            = var.schedules
  name                = "${var.lambda_config.function_name} - ${each.key}"
  description         = each.value.description
  schedule_expression = each.value.schedule_expression
}

// Create a target for the rule (the Lambda function)
resource "aws_cloudwatch_event_target" "lambda" {
  for_each = aws_cloudwatch_event_rule.lambda
  rule     = each.value.name
  arn      = aws_lambda_function.function.arn
  input    = each.value.input
}

// Create a permission that allows the CloudWatch event to invoke the Lambda
resource "aws_lambda_permission" "allow_schedule" {
  for_each      = aws_cloudwatch_event_rule.lambda
  statement_id  = "AllowExecutionFromCloudwatchEvent-${each.value.name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.arn
}
