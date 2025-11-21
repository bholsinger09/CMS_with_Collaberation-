#!/bin/bash

# SSL Setup Script for CMS Collaboration
# This script installs Certbot and obtains Let's Encrypt SSL certificates

set -e

echo "=== SSL Setup for cmscallabration.duckdns.org ==="

# Install Certbot
echo "Installing Certbot..."
sudo yum install -y certbot

# Stop nginx if running to free port 80
echo "Stopping nginx temporarily..."
docker-compose stop nginx 2>/dev/null || true

# Obtain certificate
echo "Obtaining SSL certificate..."
sudo certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email your-email@example.com \
    --domains cmscallabration.duckdns.org

# Set up certificate directories for Docker
echo "Setting up certificate directories..."
sudo mkdir -p /etc/letsencrypt-docker
sudo cp -rL /etc/letsencrypt/* /etc/letsencrypt-docker/

# Set permissions
sudo chmod -R 755 /etc/letsencrypt-docker

# Create certbot webroot for renewals
sudo mkdir -p /var/www/certbot

echo ""
echo "=== SSL Certificate Obtained Successfully ==="
echo "Certificate location: /etc/letsencrypt/live/cmscallabration.duckdns.org/"
echo ""
echo "Next steps:"
echo "1. Update docker-compose.yml to include nginx service"
echo "2. Run: docker-compose up -d"
echo "3. Your site will be available at https://cmscallabration.duckdns.org"
echo ""
echo "Certificate will auto-renew. To manually renew:"
echo "sudo certbot renew"
