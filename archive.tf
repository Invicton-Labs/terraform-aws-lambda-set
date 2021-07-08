// If the archive_output_name variable is provided, it must end in ".zip"
module "assert_proper_output_archive_name" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.1"
  count         = var.archive_output_name != null ? 1 : 0
  condition     = length(var.archive_output_name) > 4 && lower(substr(var.archive_output_name, length(var.archive_output_name) - 4, 4)) == ".zip"
  error_message = "The `archive_output_name` variable, if provided, must end in `.zip`."
}

locals {
  archive_needed           = var.source_directory != null || var.unzipped_source_file != null
  output_default_filename  = local.archive_needed ? basename("${var.source_directory != null ? var.source_directory : var.unzipped_source_file}.zip") : ""
  archive_output_directory = trimsuffix(trimsuffix(var.archive_output_directory != null ? var.archive_output_directory : path.root, "/"), "\\")
  output_fullpath          = "${local.archive_output_directory}/${local.output_default_filename}"
  // The name of the file for the Lambda resource to upload
  lambda_filename = local.archive_needed ? local.output_fullpath : var.lambda_config.filename
}

// If a directory was provided, create an archive
data "archive_file" "archive" {
  count = local.archive_needed ? 1 : 0
  type  = "zip"
  // If a sourcefile is specified, use that
  source_file = var.unzipped_source_file != null ? var.unzipped_source_file : null
  // Only use the source directory if no file is specified
  source_dir  = var.source_directory != null ? var.source_directory : null
  output_path = local.output_fullpath
}

locals {
  archive_base64sha256 = length(data.archive_file.archive) > 0 ? data.archive_file.archive[0].output_base64sha256 : (var.lambda_config.filename != null ? filebase64sha256(var.lambda_config.filename) : (var.lambda_config.source_code_hash != null ? var.lambda_config.source_code_hash : null))
}
