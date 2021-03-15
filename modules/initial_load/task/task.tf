resource "aws_iam_role" "task_role" {
  name_prefix        = "dynamodb-copy-task"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  tags               = merge(var.tags)
}

resource "aws_iam_role_policy" "task" {
  name   = "dynamodb_copy_${var.source_table_name}"
  policy = data.aws_iam_policy_document.this.json
  role   = aws_iam_role.task_role.id
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "CrossAccountAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.destination_role_arn
    ]
  }
  statement {
    sid    = "DynamoDBReadOnly"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:table/${var.source_table_name}"
    ]
  }
  statement {
    sid    = "ListTables"
    effect = "Allow"
    actions = [
      "dynamodb:ListTables"
    ]
    resources = ["*"]
  }
}


module "dynamodb-copy-container-definition" {
  source           = "cloudposse/ecs-container-definition/aws"
  version          = "0.45.2"
  container_image  = "${local.ecr_url}:prod"
  container_name   = "dynamodb-copy"
  container_memory = var.memory
  container_cpu    = var.cpuUnits
  essential        = true
  environment = [
    {
      name  = "SOURCE_TABLE_NAME"
      value = var.source_table_name
    },
    {
      name  = "DESTINATION_TABLE_NAME"
      value = var.destination_table_name
    },
    {
      name  = "DESTINATION_ROLE_ARN"
      value = var.destination_role_arn
    }
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = var.cw_log_group_name
      "awslogs-region"        = data.aws_region.this.name
      "awslogs-stream-prefix" = "copy"
    }
  }
}

resource "aws_ecs_task_definition" "td" {
  family                   = "dynamodb_copy_${var.source_table_name}"
  container_definitions    = module.dynamodb-copy-container-definition.json_map_encoded_list
  network_mode             = "awsvpc"
  cpu                      = var.cpuUnits
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  requires_compatibilities = ["FARGATE"]
  tags                     = var.tags
}
