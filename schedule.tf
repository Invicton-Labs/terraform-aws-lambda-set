// Create a rule that runs on a schedule
resource "aws_cloudwatch_event_rule" "lambda" {
  count               = length(var.schedules)
  name_prefix         = "${var.name}-${random_id.event_rule[count.index].b64_url}"
  description         = "Schedule for the Lambda function ${var.name}"
  schedule_expression = var.schedules[count.index]
}

// Create a target for the rule (the Lambda function)
resource "aws_cloudwatch_event_target" "lambda" {
  for_each = aws_cloudwatch_event_rule.lambda
  rule  = each.value.name
  arn   = aws_lambda_function.function.arn
}

// Create a permission that allows the CloudWatch event to invoke the Lambda
resource "aws_lambda_permission" "allow_schedule" {
  for_each = aws_cloudwatch_event_rule.lambda
  statement_id  = "AllowExecutionFromCloudwatchEvent-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.arn
}
