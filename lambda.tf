// Create the actual function
resource "aws_lambda_function" "function" {
  // Don't create the function until the log group has been created
  depends_on = [
    module.log_group.log_group,
    // This forces it to wait for the role permissions to be updated before updating the function
    aws_iam_role_policy_attachment.role_policy_attachment,
    aws_iam_role_policy.role_policy,
  ]
  region                         = local.region
  function_name                  = var.function_name
  role                           = local.role_arn
  architectures                  = var.lambda_config.architectures
  code_signing_config_arn        = var.lambda_config.code_signing_config_arn
  description                    = var.lambda_config.description
  filename                       = local.lambda_filename
  handler                        = var.lambda_config.handler
  image_uri                      = var.lambda_config.image_uri
  kms_key_arn                    = var.lambda_config.kms_key_arn
  layers                         = var.lambda_config.layers
  memory_size                    = var.lambda_config.memory_size
  package_type                   = var.lambda_config.package_type
  publish                        = var.lambda_config.publish
  reserved_concurrent_executions = var.lambda_config.reserved_concurrent_executions
  runtime                        = var.lambda_config.runtime
  s3_bucket                      = var.lambda_config.s3_bucket
  s3_key                         = var.lambda_config.s3_key
  s3_object_version              = var.lambda_config.s3_object_version
  source_code_hash               = local.archive_base64sha256
  tags                           = var.lambda_config.tags
  timeout                        = var.lambda_config.timeout

  dynamic "environment" {
    for_each = var.lambda_config.environment != null ? [1] : []
    content {
      variables = var.lambda_config.environment.variables
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.lambda_config.dead_letter_config != null ? [1] : []
    content {
      target_arn = var.lambda_config.dead_letter_config.target_arn
    }
  }

  dynamic "vpc_config" {
    for_each = var.lambda_config.vpc_config != null ? [1] : []
    content {
      subnet_ids         = var.lambda_config.vpc_config.subnet_ids
      security_group_ids = var.lambda_config.vpc_config.security_group_ids
    }
  }

  dynamic "tracing_config" {
    for_each = var.lambda_config.tracing_config != null ? [1] : []
    content {
      mode = var.lambda_config.tracing_config.mode
    }
  }

  dynamic "file_system_config" {
    for_each = var.lambda_config.file_system_config != null ? [1] : []
    content {
      arn              = var.lambda_config.file_system_config.arn
      local_mount_path = var.lambda_config.file_system_config.local_mount_path
    }
  }

  dynamic "image_config" {
    for_each = var.lambda_config.image_config != null ? [1] : []
    content {
      entry_point       = var.lambda_config.image_config.entry_point
      command           = var.lambda_config.image_config.command
      working_directory = var.lambda_config.image_config.working_directory
    }
  }
}

// For each service that should be able to execute this function, add a permission to do so
resource "aws_lambda_permission" "allow_execution" {
  count         = length(var.execution_services)
  region        = local.region
  statement_id  = "AllowExecutionFromService-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = var.execution_services[count.index].service
  source_arn    = var.execution_services[count.index].arn
}
