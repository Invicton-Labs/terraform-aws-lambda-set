variable "lambda_config" {
  description = "The Lambda function configuration. The variables are the same as the `aws_lambda_function` resource."
  type = object({
    filename          = optional(string)
    s3_bucket         = optional(string)
    s3_key            = optional(string)
    s3_object_version = optional(string)
    image_uri         = optional(string)
    package_type      = optional(string)
    function_name     = string
    dead_letter_config = optional(object({
      target_arn = string
    }))
    handler                        = string
    role                           = string
    description                    = optional(string)
    layers                         = optional(list(string))
    memory_size                    = optional(number)
    runtime                        = optional(string)
    timeout                        = optional(number)
    reserved_concurrent_executions = optional(number)
    publish                        = optional(bool)
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
    }))
    tracing_config = optional(object({
      mode = string
    }))
    environment = optional(object({
      variables = map(any)
    }))
    kms_key_arn      = optional(string)
    source_code_hash = optional(string)
    tags             = optional(map(string))
    file_system_config = optional(object({
      arn              = string
      local_mount_path = string
    }))
    code_signing_config_arn = optional(string)
    image_config = optional(object({
      entry_point       = optional(string)
      command           = optional(string)
      working_directory = optional(string)
    }))
  })
}

variable "edge" {
  description = "Whether this is a Lambda@Edge function."
  type        = bool
}

variable "source_directory" {
  description = "The directory that contains all files that must be bundled into the Lambda archive for upload. If this variable is provided, a ZIP archive of this directory will automatically be created and will be used for the Lambda. This variable conflicts with the `unzipped_source_file` variable and the `filename`, `s3_bucket`, `s3_key`, `s3_object_version`, `image_uri`, `package_type`, and `image_config` fields in the `lambda_config` variable."
  type        = string
  default     = null
}

variable "unzipped_source_file" {
  description = "A single source file in its unzipped state. If this variable is provided, a ZIP archive of this file will automatically be created and will be used for the Lambda. This variable conflicts with the `source_directory` variable and the `filename`, `s3_bucket`, `s3_key`, `s3_object_version`, `image_uri`, `package_type`, and `image_config` fields in the `lambda_config` variable."
  type        = string
  default     = null
}

variable "archive_output_directory" {
  description = "The directory where the Lambda archive should be saved. Only applies if the `source_directory` or `unzipped_source_file` variable is provided. Defaults to saving in the `path.root` directory."
  type        = string
  default     = path.root
}
variable "archive_output_name" {
  description = "The filename to use for the Lambda archive. Only applies if the `source_directory` or `unzipped_source_file` variable is provided. Defaults to using the name of the directory or file being archived."
  type        = string
  default     = null
}

variable "role_policy_arns" {
  description = "A list of IAM policy ARNs to attach to the role this Lambda uses for execution. This variable conflicts with the `role` field in the `lambda_config` variable (this module will not attach these policies to a provided role, as that should be done outside this module)."
  type        = list(string)
  default     = []
}

variable "cloudwatch_logs_retention_days" {
  description = "The number of days to retain CloudWatch logs for this Lambda. Default: 14."
  type        = number
  default     = 14
}

variable "cloudwatch_logs_kms_key_id" {
  description = "The ID of the KMS key to use for encrypting the CloudWatch logs for this Lambda.,"
  type        = number
  default     = null
}

variable "execution_services" {
  description = "A list of service/ARN pairs that should be allowed to invoke this Lambda. The service must be specified, but the ARN can be omitted to allow invokations from all resources in that service."
  type = list(object({
    service = string
    arn     = optional(string)
  }))
  default = []
}

variable "schedules" {
  description = "A list of schedules to run this Lambda on (uses CloudWatch Events schedule notation)."
  type        = list(string)
  default     = []
}

variable "logs_subscriptions" {
  description = "A list of configurations for Lambda subscriptions to the CloudWatch Logs Group for this Lambda. Each element should be a map with `arn` (required), `name` (optional), and `filter` (optional)."
  type = list(object({
    arn    = string
    name   = default(string, "Lambda Subscription")
    filter = default(string, "")
  }))
  default = []
}
