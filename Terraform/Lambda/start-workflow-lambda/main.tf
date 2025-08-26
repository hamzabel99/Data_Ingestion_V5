data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM role for All Lambda functions
data "aws_iam_policy_document" "start_workflow_lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "start_workflow_lambda_role" {
  name               = "start_workflow_lambda_execution_role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.start_workflow_lambda_assume_role.json
}


data "aws_iam_policy_document" "start_workflow_lambda_policy" {
 

  statement {
    sid    = "DynamoReadWorkflowMetadata"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:table/${var.workflow_statut_table_name}",
      "arn:aws:dynamodb:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:table/${var.workflow_metadata_table_name}"
    ]
  }
  
statement {
    sid    = "StartStepFunction"
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      "arn:aws:states:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.csv_to_parquet_sfn_name}"
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    ]
  }
}


resource "aws_iam_role_policy" "start_workflow_lambda_permissions" {
  name   = "lambda_permissions-${var.env}"
  role   = aws_iam_role.start_workflow_lambda_role.id
  policy = data.aws_iam_policy_document.start_workflow_lambda_policy.json
}


data "archive_file" "data_start_workflow_lambda" {
  type        = "zip"
  source_file = "${path.module}/../Code/start-workflow-lambda/start-workflow-lambda.py"
  output_path = "${path.module}/../Code/start-workflow-lambda/start-workflow-lambda.zip"
}


resource "aws_lambda_function" "start_workflow_lambda" {
  filename      = data.archive_file.data_start_workflow_lambda.output_path
  function_name = "start_workflow_lambda-${var.env}"
  role          = aws_iam_role.start_workflow_lambda_role.arn
  handler       = "start-workflow-lambda.lambda_handler"

  runtime = "python3.12"

  environment {
    variables = {
      WORKFLOW_METADATA_TABLE = var.workflow_metadata_table_name
      WORKFLOW_STATUS_TABLE    = var.workflow_statut_table_name
    }
  }
}


