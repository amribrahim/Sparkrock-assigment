variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
  default     = "eu-central-1"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "sparkrock"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "staging"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "alert_email" {
  type        = string
  description = "Email to subscribe to CPU CloudWatch alarm SNS topic"
  default     = "changeme@example.com"
}
