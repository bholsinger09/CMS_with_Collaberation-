#!/bin/bash

# Complete AWS Instance Setup and Verification
# Run this on your EC2 instance: ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@18.215.152.2

set -e

echo "🚀 CMS Collaboration - Complete Setup"
echo "======================================"
echo ""

# Check if running on EC2
if [ ! -d "/home/ubuntu" ]; then
    echo "⚠️  Warning: This script is meant to run on AWS EC2 Ubuntu instance"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Step 1: Installing Docker and Docker Compose..."
echo "================================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

echo ""
echo "Step 2: Cloning/Updating Repository..."
echo "======================================="

if [ -d "CMS_with_Collaberation-" ]; then
    echo "Repository exists, pulling latest changes..."
    cd CMS_with_Collaberation-
    git pull origin main
else
    echo "Cloning repository..."
    git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
    cd CMS_with_Collaberation-
fi

echo "✅ Code updated"
echo ""

echo "Step 3: Creating Environment Files..."
echo "======================================"

# Frontend environment
cat > frontend/.env << 'EOF'
VITE_API_URL=http://cmscallabration.duckdns.org:5000
VITE_PHP_URL=http://cmscallabration.duckdns.org:8080
VITE_WS_URL=ws://cmscallabration.duckdns.org:5000
EOF
echo "✅ Frontend .env created"

# Backend environment
cat > backend/.env << 'EOF'
ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://+:80
EOF
echo "✅ Backend .env created"

# PHP environment
cat > php-server/.env << 'EOF'
DB_HOST=mysql
DB_DATABASE=cms_collaboration
DB_USERNAME=cmsuser
DB_PASSWORD=cmspassword
DB_PORT=3306
EOF
echo "✅ PHP .env created"

echo ""
echo "Step 4: Stopping Existing Containers..."
echo "========================================"

docker-compose down -v 2>/dev/null || true
echo "✅ Containers stopped"

echo ""
echo "Step 5: Building and Starting Services..."
echo "=========================================="

# Build without cache to ensure fresh build
docker-compose build --no-cache
docker-compose up -d

echo "✅ Services starting..."
echo ""

echo "Step 6: Waiting for Services to Initialize..."
echo "=============================================="

echo "Waiting 60 seconds for all services to start..."
for i in {1..60}; do
    echo -n "."
    sleep 1
done
echo ""

echo ""
echo "Step 7: Checking Service Status..."
echo "==================================="

docker-compose ps
echo ""

echo "Step 8: Checking Individual Services..."
echo "========================================"

# Check MySQL
echo "MySQL:"
docker-compose exec -T mysql mysqladmin ping -h localhost -u root -prootpassword 2>&1 | head -1
echo ""

# Check Backend
echo "Backend:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:5000/swagger/index.html || echo "Backend not responding"
echo ""

# Check PHP
echo "PHP Server:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8080 || echo "PHP not responding"
echo ""

# Check Frontend
echo "Frontend:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:3000 || echo "Frontend not responding"
echo ""

echo "Step 9: Viewing Recent Logs..."
echo "================================"

echo ""
echo "=== Frontend Logs ==="
docker-compose logs --tail=20 frontend
echo ""

echo "=== Backend Logs ==="
docker-compose logs --tail=20 backend
echo ""

echo "=== PHP Logs ==="
docker-compose logs --tail=20 php-server
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
echo "📋 Useful Commands:"
echo "   View logs:    docker-compose logs -f"
echo "   Restart:      docker-compose restart"
echo "   Stop:         docker-compose down"
echo "   Status:       docker-compose ps"
echo ""
echo "🔍 If frontend is still blank:"
echo "   1. Check logs: docker-compose logs frontend"
echo "   2. Check browser console (F12)"
echo "   3. Verify port 3000 is open in AWS Security Group"
echo "   4. Try: docker-compose restart frontend"
echo ""

# Save setup info
cat > setup-info.txt << EOF
CMS Collaboration Platform - Setup Complete
===========================================
Date: $(date)
Instance: $(hostname)

Services:
- Frontend: http://cmscallabration.duckdns.org:3000
- Backend:  http://cmscallabration.duckdns.org:5000
- Swagger:  http://cmscallabration.duckdns.org:5000/swagger
- PHP:      http://cmscallabration.duckdns.org:8080

Login:
- Email: admin@cms.local
- Password: admin123

Container Status:
$(docker-compose ps)
EOF

echo "📄 Setup information saved to: setup-info.txt"
