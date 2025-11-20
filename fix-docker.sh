#!/bin/bash

# Fix Docker and Docker Compose for Amazon Linux
# Run this on your EC2 instance

set -e

echo "🔧 Fixing Docker and Docker Compose..."
echo "======================================="
echo ""

# Stop and remove old docker
sudo systemctl stop docker 2>/dev/null || true
sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true

echo "Installing latest Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

echo ""
echo "Installing Docker Compose V2..."
# Remove old docker-compose
sudo rm -f /usr/local/bin/docker-compose

# Install Docker Compose plugin
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Also install as standalone
sudo curl -L https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo ""
echo "✅ Docker and Docker Compose updated!"
echo ""

# Verify
docker --version
docker-compose --version || docker compose version

echo ""
echo "⚠️  IMPORTANT: You need to log out and back in for group changes"
echo ""
echo "Run these commands:"
echo "1. exit"
echo "2. ssh back in"
echo "3. cd ~/CMS_with_Collaberation-"
echo "4. ./deploy-simple.sh"
