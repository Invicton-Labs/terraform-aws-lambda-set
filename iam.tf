locals {
  shortened_role_name_prefix = length(var.function_name) <= 31 ? var.function_name : "${substr(var.function_name, 0, 15)}-${substr(var.function_name, length(var.function_name) - 15, 15)}"
}

module "iam_role_provided" {
  source  = "Invicton-Labs/input-provided/null"
  version = "~>0.2.0"
  input   = var.iam_role_arn
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = concat(
        ["lambda.amazonaws.com"],
        var.edge ? ["edgelambda.amazonaws.com"] : []
      )
    }
    condition {
      test     = "ArnEquals"
      variable = "iam:AssociatedResourceARN"
      values = [
        "arn:aws:lambda:${local.region}:${data.aws_caller_identity.current.account_id}:function:${var.function_name}"
      ]
    }
  }
}

// If no role was provided, create a new one
resource "aws_iam_role" "lambda_role" {
  count                 = module.iam_role_provided.provided ? 0 : 1
  name_prefix           = "${local.shortened_role_name_prefix}-"
  path                  = "/lambda/"
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
}

// Split up the Lambda role's ARN
data "aws_arn" "lambda_role" {
  arn = var.iam_role_arn != null ? var.iam_role_arn : aws_iam_role.lambda_role[0].arn
}

locals {
  role_name_parts = split("/", data.aws_arn.lambda_role.resource)
  // The role name includes "/role/..." and we don't want the "role" part
  role_id  = local.role_name_parts[length(local.role_name_parts) - 1]
  role_arn = data.aws_arn.lambda_role.arn
}

// Attach a policy that allows it to write logs
resource "aws_iam_role_policy" "cloudwatch_write" {
  // Only attach the policy if a new role was created OR it should be applied to the existing role
  count = var.iam_role_arn == null || var.add_cloudwatch_logs_access_to_role ? 1 : 0
  name  = "cloudwatch-write"
  // Extract the role name from the ARN, since this resource can't handle an ARN here
  role   = local.role_id
  policy = module.log_group.logging_policy_json
}

// If necessary, attach a policy that allows it to access the VPC
resource "aws_iam_role_policy" "vpc_access" {
  // Only attach the policy if VPC config was given AND either a new role was created or it should be applied to the existing role
  count = var.lambda_config.vpc_config != null && (var.iam_role_arn == null || var.add_vpc_access_to_role) ? 1 : 0
  name  = "vpc-access"
  role  = local.role_id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ec2:CreateNetworkInterface",
              "ec2:DescribeNetworkInterfaces",
              "ec2:DeleteNetworkInterface"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

// Attach any policies provided as arguments
resource "aws_iam_role_policy" "role_policy" {
  count  = length(var.role_policies)
  role   = local.role_id
  policy = var.role_policies[count.index]
}

// Attach any policy ARNs provided as arguments
resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  count      = length(var.role_policy_arns)
  role       = local.role_id
  policy_arn = var.role_policy_arns[count.index]
}
