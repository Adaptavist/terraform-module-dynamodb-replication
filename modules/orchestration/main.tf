data "aws_region" "this" {}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "dynamodb_replication_"
  role_arn = aws_iam_role.step-function-exec.arn
  tags     = var.tags

  definition = templatefile("${path.module}/step-function.json", {
    helper_lambda_arn = var.helper_lambda_arn
    glue_job_name     = var.glue_job_name
  })
}

data "aws_iam_policy_document" "step-function-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.${data.aws_region.this.name}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "step-function-exec" {
  name_prefix        = "step-function-exec"
  assume_role_policy = data.aws_iam_policy_document.step-function-assume-role.json
  tags               = var.tags
}

## Schedule step function to run hourly

resource "aws_cloudwatch_event_rule" "step_function_scheduler" {
  name_prefix         = "dynamodb-replication-scheduler"
  description         = "Schedules dynamo db replication setup"
  schedule_expression = "rate(1 day)"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "cloudwatch_target" {
  rule      = aws_cloudwatch_event_rule.step_function_scheduler.name
  target_id = "StartETLStepFunction"
  arn       = aws_sfn_state_machine.sfn_state_machine.id
  role_arn  = aws_iam_role.cloudwatch.arn
}

data "aws_iam_policy_document" "cloudwatch-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch" {
  name_prefix        = "scheduler"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch-assume-role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "step_functions_invoke" {
  statement {
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.sfn_state_machine.id
    ]
  }
}

resource "aws_iam_policy" "step_functions_invoke" {
  name_prefix = "step-function-invoke"
  policy      = data.aws_iam_policy_document.step_functions_invoke.json
}

resource "aws_iam_role_policy_attachment" "step_function_invoke" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = aws_iam_policy.step_functions_invoke.arn
}

// allow state machine to invoke lambdas

resource "aws_lambda_permission" "allow_sfn_invoke_helper" {
  statement_id  = "AllowExecutionFromStateMachine"
  action        = "lambda:InvokeFunction"
  function_name = var.helper_function_name
  principal     = "states.amazonaws.com"
  source_arn    = aws_sfn_state_machine.sfn_state_machine.id
}


data "aws_iam_policy_document" "invoke_lambda" {
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      var.helper_lambda_arn
    ]
  }
}

resource "aws_iam_policy" "invoke_lambdas" {
  name_prefix = "invoke-lambdas"
  policy      = data.aws_iam_policy_document.invoke_lambda.json
}

resource "aws_iam_role_policy_attachment" "allow_sfn_invoke_lambda" {
  role       = aws_iam_role.step-function-exec.name
  policy_arn = aws_iam_policy.invoke_lambdas.arn
}
