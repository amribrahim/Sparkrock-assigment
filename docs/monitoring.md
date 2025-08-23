# Monitoring & Alerts

- CloudWatch metric alarm: `CPUUtilization > 70%` for 2 periods of 5 minutes.
- Alert target: SNS topic `${project}-${environment}-alerts` with your email.
- Confirm the SNS subscription from your inbox after `terraform apply`.
