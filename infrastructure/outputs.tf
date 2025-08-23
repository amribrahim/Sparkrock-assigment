output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "application_https_url" {
  value = "https://${aws_instance.app.public_ip}"
}

output "ecr_api_repo_url" {
  value = aws_ecr_repository.api.repository_url
}

output "ecr_web_repo_url" {
  value = aws_ecr_repository.web.repository_url
}
