#!/bin/bash
set -euxo pipefail

# Install Docker, docker compose plugin, awscli, openssl
yum update -y
amazon-linux-extras install docker -y || yum install -y docker
yum install -y docker-compose-plugin awscli openssl

systemctl enable docker
systemctl start docker

# allow ec2-user to run docker
usermod -aG docker ec2-user || true

mkdir -p /opt/sparkrock/nginx
mkdir -p /opt/sparkrock/certs

# Generate a self-signed certificate (valid 365 days). Replace with ACM/real cert in production.
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/CN=${project}.${environment}.local" \
  -keyout /opt/sparkrock/certs/selfsigned.key \
  -out /opt/sparkrock/certs/selfsigned.crt

# Write nginx.conf
cat > /opt/sparkrock/nginx/nginx.conf <<"NGINXCONF"
worker_processes auto;
events { worker_connections 1024; }
http {
  sendfile on;
  server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
  }
  server {
    listen 443 ssl;
    server_name _;
    ssl_certificate     /etc/nginx/certs/selfsigned.crt;
    ssl_certificate_key /etc/nginx/certs/selfsigned.key;

    # Basic auth for everything
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/htpasswd/.htpasswd;

    location /api/ {
      proxy_pass http://api:3000/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
      proxy_pass http://web:80/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
  }
}
NGINXCONF

# Create a default basic-auth user 'admin' with password 'admin' (overwritten by CI/CD on deploy)
echo "admin:$(openssl passwd -apr1 admin)" > /opt/sparkrock/nginx/.htpasswd

# docker-compose file
cat > /opt/sparkrock/docker-compose.yml <<'COMPOSE'
version: "3.8"
services:
  api:
    image: ${api_repo}:latest
    restart: unless-stopped
    networks: [appnet]
  web:
    image: ${web_repo}:latest
    restart: unless-stopped
    networks: [appnet]
  reverse-proxy:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/.htpasswd:/etc/nginx/htpasswd/.htpasswd:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - api
      - web
    networks: [appnet]
networks:
  appnet: {}
COMPOSE

# Login to ECR for initial pulls (will be updated by CI/CD soon)
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${region}.amazonaws.com || true

# Start stack (will fail until images exist; that's ok)
cd /opt/sparkrock
docker compose up -d || true
