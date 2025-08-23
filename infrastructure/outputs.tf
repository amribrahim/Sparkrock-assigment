output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_instance.public_ip
}

output "application_https_url" {
  description = "HTTPS URL for the application"
  value       = "https://${aws_instance.app_instance.public_ip}"
}

output "application_http_url" {
  description = "HTTP URL for the application (port 8080 - nginx reverse proxy)"
  value       = "http://${aws_instance.app_instance.public_ip}:8080"
}

output "application_direct_url" {
  description = "Direct HTTP URL for the application (port 80)"
  value       = "http://${aws_instance.app_instance.public_ip}"
}

output "ecr_api_repo_url" {
  description = "URL of the ECR repository for the API"
  value       = aws_ecr_repository.api.repository_url
}

output "ecr_web_repo_url" {
  description = "URL of the ECR repository for the web frontend"
  value       = aws_ecr_repository.web.repository_url
}
