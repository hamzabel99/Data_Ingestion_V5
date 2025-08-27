output "daily_monitor_lambda_ecr_repo_url" {
  value = aws_ecr_repository.daily_monitor_lambda_ecr_repo.repository_url
}