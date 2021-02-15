data "aws_caller_identity" "this" {}

resource "aws_iam_role" "dynamodb_writer" {
  name_prefix        = "dynamodb_writer"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  tags               = var.tags
}


data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.source_account_number]
    }
  }
}

data "aws_iam_policy_document" "allow_dynamodb_access" {
  statement {
    sid     = "AllowDynamoDBAccess"
    effect  = "Allow"
    actions = ["dynamodb:*"]
    resources = [
      "arn:aws:dynamodb:*:${data.aws_caller_identity.this.account_id}:table/${var.target_table_name}"
    ]
  }
}

resource "aws_iam_role_policy" "allow_dynamodb_access" {
  name   = "allow_dynamodb_access"
  policy = data.aws_iam_policy_document.allow_dynamodb_access.json
  role   = aws_iam_role.dynamodb_writer.id
}