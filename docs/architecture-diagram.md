# Architecture Diagram - Sparkrock Assignment

## System Overview
This document describes the complete architecture of the Sparkrock assignment infrastructure and deployment pipeline.

## Architecture Components

### 1. Infrastructure Layer (AWS)
- **VPC**: 10.0.0.0/16 with 2 public subnets across AZs
- **EC2 Instance**: t3.micro running Amazon Linux 2
- **ECR Repositories**: For API and Web container images
- **Security Groups**: HTTPS (443) and HTTP redirect (80)
- **IAM Roles**: EC2 instance profile with ECR and SSM permissions

### 2. Application Layer
- **Reverse Proxy**: Nginx with HTTPS termination and Basic Auth
- **Backend API**: Node.js Express server (port 3000)
- **Frontend**: Static HTML/JS served via Nginx (port 80)
- **Docker Compose**: Orchestrates all containers

### 3. CI/CD Pipeline
- **GitHub Actions**: Triggers on push to main branch
- **Build Process**: Docker image creation and ECR push
- **Deployment**: AWS SSM commands for zero-downtime deployment
- **Authentication**: Updates Basic Auth credentials from secrets

### 4. Monitoring & Security
- **CloudWatch**: CPU utilization monitoring (>70% threshold)
- **SNS**: Email alerts for high CPU usage
- **HTTPS**: Self-signed certificates (staging environment)
- **Basic Auth**: HTTP authentication for all routes

## Network Flow
```
Internet → HTTPS (443) → Nginx Reverse Proxy → Basic Auth → Frontend/API
                    ↓
              HTTP (80) → HTTPS Redirect
```

## Deployment Flow
```
Code Push → GitHub Actions → Build Images → Push to ECR → SSM Deploy → Restart Services
```

## Security Features
- HTTPS enforcement
- Basic authentication
- Security group restrictions
- IAM least privilege
- Container image scanning
