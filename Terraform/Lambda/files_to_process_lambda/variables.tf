variable "aws_sqs_queue_arn" {
  description = "ARN of the SQS queue"
  type        = string

}

variable "env" {
}

variable "aws_sqs_queue_name" {
  description = "Name of the SQS queue"
  type = string
  
}

variable "workflow_statut_table_name" {
  description = "Name of the Dynamo DB workflow-statut"
  type  = string
  
}