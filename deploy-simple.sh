#!/bin/bash

# Simple Deployment Script - No complex builds required
# Run after fix-docker.sh

set -e

echo "🚀 Simple Deployment - CMS Collaboration"
echo "========================================="
echo ""

cd ~/CMS_with_Collaberation-

echo "Step 1: Pull latest code..."
git pull origin main 2>/dev/null || echo "Already up to date"

echo ""
echo "Step 2: Create environment files..."

cat > frontend/.env << 'EOF'
VITE_API_URL=http://cmscallabration.duckdns.org:5000
VITE_PHP_URL=http://cmscallabration.duckdns.org:8080
VITE_WS_URL=ws://cmscallabration.duckdns.org:5000
EOF

cat > backend/.env << 'EOF'
ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://+:80
EOF

cat > php-server/.env << 'EOF'
DB_HOST=mysql
DB_DATABASE=cms_collaboration
DB_USERNAME=cmsuser
DB_PASSWORD=cmspassword
DB_PORT=3306
EOF

echo "✅ Environment files created"

echo ""
echo "Step 3: Stop existing containers..."
docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true

echo ""
echo "Step 4: Pull pre-built images (if available)..."
docker compose pull 2>/dev/null || echo "No pre-built images, will build locally"

echo ""
echo "Step 5: Starting services..."
# Try docker compose (v2) first, fallback to docker-compose (v1)
if docker compose version &>/dev/null; then
    docker compose up -d --build
else
    docker-compose up -d --build
fi

echo ""
echo "✅ Services started!"
echo ""

echo "Waiting 30 seconds for initialization..."
sleep 30

echo ""
echo "Step 6: Checking status..."
if docker compose version &>/dev/null; then
    docker compose ps
else
    docker-compose ps
fi

echo ""
echo "============================================"
echo "✅ Deployment Complete!"
echo "============================================"
echo ""
echo "🌐 Access URLs:"
echo "   Frontend:  http://cmscallabration.duckdns.org:3000"
echo "   Backend:   http://cmscallabration.duckdns.org:5000/swagger"
echo "   PHP:       http://cmscallabration.duckdns.org:8080"
echo ""
echo "🔑 Login:"
echo "   Email:    admin@cms.local"
echo "   Password: admin123"
echo ""
echo "📋 View Logs:"
echo "   docker compose logs -f"
echo "   docker compose logs -f frontend"
echo ""
