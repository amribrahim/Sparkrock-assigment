#!/bin/bash

# Update system and install prerequisites
sudo su 
yum update -y
yum install -y docker git aws-cli

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose



# Create application directory
mkdir -p /opt/sparkrock-app
cd /opt/sparkrock-app

# Authenticate with ECR
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${region}.amazonaws.com

# Create docker-compose.yml file
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  api:
    image: ${api_repo}
    container_name: sparkrock-api
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=staging
    restart: unless-stopped

  web:
    image: ${web_repo}
    container_name: sparkrock-web
    ports:
      - "80:80"
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: sparkrock-nginx
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - api
      - web
    restart: unless-stopped
EOF

# Create nginx configuration
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api_backend {
        server api:3000;
    }

    upstream web_backend {
        server web:80;
    }

    server {
        listen 80;
        server_name _;

        # API endpoints
        location /api/ {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Web frontend
        location / {
            proxy_pass http://web_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# Start the services
echo "=== Starting Docker services ==="
/usr/local/bin/docker-compose up -d

# Wait a moment for services to start
sleep 50

# Create a simple test page
echo "=== Creating test page ==="
docker exec sparkrock-nginx sh -c "echo '<h1>Sparkrock Assignment - Nginx is Working!</h1><p>If you see this, the infrastructure is running correctly.</p>' > /usr/share/nginx/html/test.html"

echo "=== Infrastructure setup complete ==="
echo "=== Test URLs ==="
echo "Main app: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "Test page: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080/test.html"
echo "API health: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000/api/health"
echo "Web service: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):80"
