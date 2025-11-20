#!/bin/bash

# Amazon Linux / ec2-user Setup Script
# For instances running Amazon Linux (not Ubuntu)

set -e

echo "🚀 CMS Collaboration - Amazon Linux Setup"
echo "=========================================="
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Detected OS: $NAME"
    echo ""
fi

echo "Step 1: Installing System Dependencies..."
echo "=========================================="

# Update system
sudo yum update -y

# Install Git
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    sudo yum install -y git
    echo "✅ Git installed"
else
    echo "✅ Git already installed"
fi

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

echo ""
echo "Step 2: Cloning Repository..."
echo "=============================="

cd ~

if [ -d "CMS_with_Collaberation-" ]; then
    echo "Repository exists, pulling updates..."
    cd CMS_with_Collaberation-
    git pull origin main
else
    echo "Cloning repository..."
    git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
    cd CMS_with_Collaberation-
fi

echo "✅ Code ready"
echo ""

echo "Step 3: Creating Environment Files..."
echo "======================================"

# Frontend
cat > frontend/.env << 'EOF'
VITE_API_URL=http://cmscallabration.duckdns.org:5000
VITE_PHP_URL=http://cmscallabration.duckdns.org:8080
VITE_WS_URL=ws://cmscallabration.duckdns.org:5000
EOF
echo "✅ Frontend .env"

# Backend
cat > backend/.env << 'EOF'
ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://+:80
EOF
echo "✅ Backend .env"

# PHP
cat > php-server/.env << 'EOF'
DB_HOST=mysql
DB_DATABASE=cms_collaboration
DB_USERNAME=cmsuser
DB_PASSWORD=cmspassword
DB_PORT=3306
EOF
echo "✅ PHP .env"

echo ""
echo "Step 4: Starting Docker Service..."
echo "==================================="

sudo systemctl start docker
sudo systemctl enable docker
echo "✅ Docker running"

echo ""
echo "Step 5: Building and Starting Services..."
echo "=========================================="

# Stop any existing containers
sudo docker-compose down 2>/dev/null || true

# Build and start
sudo docker-compose build
sudo docker-compose up -d

echo "✅ Services starting..."
echo ""

echo "Waiting 60 seconds for services to initialize..."
for i in {1..60}; do
    echo -n "."
    sleep 1
done
echo ""

echo ""
echo "Step 6: Checking Status..."
echo "=========================="

sudo docker-compose ps
echo ""

echo "============================================"
echo "✅ Setup Complete!"
echo "============================================"
echo ""
echo "🌐 Access URLs:"
echo "   Frontend:  http://cmscallabration.duckdns.org:3000"
echo "   Backend:   http://cmscallabration.duckdns.org:5000"
echo "   Swagger:   http://cmscallabration.duckdns.org:5000/swagger"
echo "   PHP:       http://cmscallabration.duckdns.org:8080"
echo ""
echo "🔑 Default Login:"
echo "   Email:    admin@cms.local"
echo "   Password: admin123"
echo ""
echo "⚠️  NOTE: You may need to log out and back in for Docker group changes"
echo "   Run: exit"
echo "   Then reconnect and run: cd ~/CMS_with_Collaberation- && sudo docker-compose ps"
echo ""
echo "📋 View Logs:"
echo "   sudo docker-compose logs -f frontend"
echo "   sudo docker-compose logs -f backend"
echo ""
