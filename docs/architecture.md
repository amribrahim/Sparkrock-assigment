# Architecture (Staging)

```mermaid
flowchart LR
  dev[Developer Push to GitHub] -->|GitHub Actions| ecr[(Amazon ECR)]
  ecr -->|docker pull| ec2[[EC2 Instance]]
  internet((Internet)) -->|HTTPS 443| rp(Reverse Proxy Nginx in Docker)
  ec2 --> rp
  rp -->|/ ->| web[Frontend (Nginx)]
  rp -->|/api ->| api[Backend (Node.js)]
  ec2 -->|CPU metrics| cw[CloudWatch Alarm >70%]
  cw --> sns[SNS Email]
```

**Notes**

- One EC2 instance (Amazon Linux 2) in a public subnet hosts Docker with three containers: `reverse-proxy`, `web`, and `api`.
- The reverse proxy terminates **HTTPS** (self-signed for demo) and enforces **HTTP Basic Auth**.
- CI/CD uses **GitHub Actions** to build images and push to **Amazon ECR**, then deploys via **AWS SSM** (no SSH).
- Basic observability: CloudWatch CPU alarm >70% notifies an **SNS email subscription**.
