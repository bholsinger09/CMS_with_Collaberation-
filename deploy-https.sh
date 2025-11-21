#!/bin/bash

# Complete SSL Deployment Script
set -e

echo "=== CMS Collaboration - HTTPS Deployment ==="
echo ""

# Check if running on EC2
if [ ! -f /home/ec2-user/CMS_Callaberation/docker-compose.yml ]; then
    echo "Error: This script must be run on the EC2 instance"
    echo "Please SSH to your EC2 instance first:"
    echo "ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94"
    exit 1
fi

cd /home/ec2-user/CMS_Callaberation

# Pull latest changes
echo "Pulling latest code from GitHub..."
git pull

# Stop existing services
echo "Stopping existing services..."
docker-compose down

# Install Certbot if not installed
if ! command -v certbot &> /dev/null; then
    echo "Installing Certbot..."
    sudo yum install -y certbot
fi

# Obtain SSL certificate
echo ""
echo "Obtaining SSL certificate for cmscallabration.duckdns.org..."
echo "NOTE: Port 80 must be accessible from the internet for this to work"
echo ""

# Check if certificate already exists
if [ -d "/etc/letsencrypt/live/cmscallabration.duckdns.org" ]; then
    echo "Certificate already exists. Checking if renewal is needed..."
    sudo certbot renew --dry-run
else
    echo "Obtaining new certificate..."
    read -p "Enter your email address for Let's Encrypt notifications: " email
    
    sudo certbot certonly --standalone \
        --non-interactive \
        --agree-tos \
        --email "$email" \
        --domains cmscallabration.duckdns.org
fi

# Set up certificate directories for Docker
echo "Setting up certificate access for Docker..."
sudo chmod -R 755 /etc/letsencrypt/live
sudo chmod -R 755 /etc/letsencrypt/archive

# Create certbot webroot for renewals
sudo mkdir -p /var/www/certbot

# Start services with nginx
echo "Starting services with HTTPS..."
docker-compose up -d --build

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Check service status
echo ""
echo "=== Service Status ==="
docker-compose ps

echo ""
echo "=== Testing HTTPS Connection ==="
curl -I https://cmscallabration.duckdns.org 2>&1 | head -5 || echo "HTTPS not responding yet (may need security group update)"

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Your CMS is now available at:"
echo "  https://cmscallabration.duckdns.org"
echo ""
echo "IMPORTANT: Update AWS Security Group to allow:"
echo "  - Port 80 (HTTP) from 0.0.0.0/0 - for Let's Encrypt renewals"
echo "  - Port 443 (HTTPS) from 0.0.0.0/0 - for secure access"
echo ""
echo "Certificate will auto-renew. To manually renew:"
echo "  sudo certbot renew"
echo "  docker-compose restart nginx"
echo ""
