terraform {
  required_version = ">= 0.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.16.0"
    }

  }

}
provider "aws" {
  region = "us-east-1"
}


locals {
  s3_names = [for backet in ["sourcebucket", "sourcebucket-resized"] : join("-", [var.namespace, backet])]
}

resource "aws_s3_bucket" "module8-s3" {
  for_each      = toset(local.s3_names)
  bucket        = each.value
  force_destroy = t

  tags = {
    Name = each.value
  }
}

resource "aws_s3_bucket_acl" "module8-s3-acl" {
  for_each = toset(local.s3_names)
  bucket   = each.value
  acl      = "private"

}

resource "aws_iam_policy" "module8-s3-iam-policy" {
  name        = var.iam-policy-name
  description = "IAM policy for S3"
  policy      = data.aws_iam_policy_document.module8-policy_doc.json
}

data "aws_iam_policy_document" "module8-policy_doc" {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream"
    ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    effect = "Allow"
    // resources = ["arn:aws:s3:::${each.value}/*"]
    resources = ["arn:aws:s3:::${local.s3_names[0]}/*"]
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect = "Allow"
    // resources = ["arn:aws:s3:::${each.value}/*"]
    resources = ["arn:aws:s3:::${local.s3_names[1]}/*"]
  }
}

data "aws_iam_policy_document" "module8-s3-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "module8-iam-role" {
  name               = var.iam-role-name
  assume_role_policy = data.aws_iam_policy_document.module8-s3-assume-role-policy.json

}

resource "aws_iam_role_policy_attachment" "module8-iam-role-policy-attachment" {
  role       = aws_iam_role.module8-iam-role.name
  policy_arn = aws_iam_policy.module8-s3-iam-policy.arn
}

resource "aws_lambda_function" "module8-lambda-function" {
  function_name    = "CreateThumbnail"
  role             = aws_iam_role.module8-iam-role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")

  tags = {
    Name = "CreateThumbnail"
  }
}

resource "aws_lambda_permission" "module8-lambda-permission" {
  statement_id  = "s3invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.module8-lambda-function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${local.s3_names[0]}"
}

resource "aws_s3_bucket_notification" "module8-bucket-notification" {
  bucket = aws_s3_bucket.module8-s3[local.s3_names[0]].id

  lambda_function {

    lambda_function_arn = aws_lambda_function.module8-lambda-function.arn
    events              = ["s3:ObjectCreated:*"]

  }

  depends_on = [aws_lambda_permission.module8-lambda-permission]
}