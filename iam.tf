locals {
  shortened_role_name_prefix = length(var.name) <= 31 ? var.name : "${substr(var.name, 0, 15)}-${substr(var.name, length(var.name) - 15, 15)}"
  lambda_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.lambda_config.function_name}"
}

// If no role was provided, create a new one
resource "aws_iam_role" "lambda_role" {
  count                 = var.lambda_config.role == null ? 1 : 0
  name_prefix           = "${local.shortened_role_name_prefix}-"
  path                  = "/lambda/"
  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          ${var.edge ? "\"edgelambda.amazonaws.com\"," : ""}
          "lambda.amazonaws.com"
        ],
      },
      "Condition": {
        "ArnEquals": {
          "aws:PrincipalArn":[
            "${local.lambda_arn}"
          ]
        }
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// Split up the Lambda role's ARN
data "aws_arn" "lambda_role" {
  arn = var.lambda_config.role != null ? var.lambda_config.role != null : aws_iam_role.lambda_role[0].arn
}

locals {
  role_name_parts = split("/", data.aws_arn.lambda_role.resource)
  // The role name includes "/role/..." and we don't want the "role" part
  role_id = local.role_name_parts[length(local.role_name_parts) - 1]
  role_arn = data.aws_arn.labmda_role.arn
}

// Attach a policy that allows it to write logs
resource "aws_iam_role_policy" "cloudwatch_write" {
  name   = "cloudwatch-write"
  // Extract the role name from the ARN, since this resource can't handle an ARN here
  role   = local.role_id
  policy = module.logging.logging_policy_json
}

// If necessary, attach a policy that allows it to access the VPC
resource "aws_iam_role_policy" "vpc_access" {
  count = var.lambda_config.vpc_config != null ? 1 : 0
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
resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  count      = length(var.role_policy_arns)
  role       = local.role_id
  policy_arn = var.role_policy_arns[count.index]
}
