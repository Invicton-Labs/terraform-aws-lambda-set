// Assert that we've only provided a single source for the Lambda code
module "assert_single_source1" {
  source  = "Invicton-Labs/assertion/null"
  version = "~>0.2.4"
  condition = var.source_directory == null || (
    var.unzipped_source_file == null &&
    var.lambda_config.filename == null &&
    var.lambda_config.s3_bucket == null &&
    var.lambda_config.s3_key == null &&
    var.lambda_config.s3_object_version == null &&
    var.lambda_config.image_uri == null &&
    var.lambda_config.package_type == null &&
    var.lambda_config.image_config == null
  )
  error_message = "The `source_directory` variable cannot be provided if the `unzipped_source_file` variable or any of the `filename`, `s3_bucket`, `s3_key`, `s3_object_version`, `image_uri`, `package_type`, or `image_config` fields in the `lambda_config` variable are provided."
}
module "assert_single_source2" {
  source  = "Invicton-Labs/assertion/null"
  version = "~>0.2.4"
  condition = var.unzipped_source_file == null || (
    var.source_directory == null &&
    var.lambda_config.filename == null &&
    var.lambda_config.s3_bucket == null &&
    var.lambda_config.s3_key == null &&
    var.lambda_config.s3_object_version == null &&
    var.lambda_config.image_uri == null &&
    var.lambda_config.package_type == null &&
    var.lambda_config.image_config == null
  )
  error_message = "The `unzipped_source_file` variable cannot be provided if the `source_directory` variable or any of the `filename`, `s3_bucket`, `s3_key`, `s3_object_version`, `image_uri`, `package_type`, or `image_config` fields in the `lambda_config` variable are provided."
}
// Ensure that if a filename is provided, no source hash is provided (it will automatically be calculated)
module "assert_filename_source_hash" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.4"
  condition     = var.lambda_config.filename == null ? true : var.lambda_config.source_code_hash == null
  error_message = "The `source_code_hash` field in the `lambda_config` variable cannot be provided if the `filename` field in the `lambda_config` variable is provided (the source file hash will be automatically calculated)."
}

// Ensure that if an IAM role for the Lambda execution was provided, there weren't also IAM policy ARNs provided
module "assert_no_policy_arns_for_provided_role" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.4"
  condition     = var.lambda_config.role == null ? true : length(var.role_policy_arns) == 0
  error_message = "The `role_policy_arns` variable cannot be provided if the `role` field in the `lambda_config` variable is provided."
}

// Ensure that if an IAM role for the Lambda execution was provided, there weren't also IAM policies provided
module "assert_no_policies_for_provided_role" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.4"
  condition     = var.lambda_config.role == null ? true : length(var.role_policies) == 0
  error_message = "The `role_policies` variable cannot be provided if the `role` field in the `lambda_config` variable is provided."
}

// Ensure that Edge functions are only defined in the us-east-1 region
module "assert_edge_region" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.4"
  condition     = !var.edge ? true : data.aws_region.current.name == "us-east-1"
  error_message = "If the `edge` variable is `true`, the lambda must be created in the `us-east-1` region."
}

// Ensure that Edge functions are published
module "assert_edge_published" {
  source        = "Invicton-Labs/assertion/null"
  version       = "~>0.2.4"
  condition     = !var.edge ? true : var.lambda_config.publish == true
  error_message = "If the `edge` variable is `true`, the `publish` variable in `lambda_config` must also be `true`."
}
