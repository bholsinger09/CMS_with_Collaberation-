#!/bin/bash

# Quick Fix Script for Frontend Issues
# Run this on your AWS EC2 instance

set -e

echo "🔧 Fixing CMS Collaboration Frontend"
echo "====================================="
echo ""

cd ~/CMS_with_Collaberation-

echo "1️⃣ Pulling latest code..."
git pull origin main
echo ""

echo "2️⃣ Stopping containers..."
docker-compose down
echo ""

echo "3️⃣ Creating proper environment file..."
cat > frontend/.env << 'EOF'
VITE_API_URL=http://cmscallabration.duckdns.org:5000
VITE_PHP_URL=http://cmscallabration.duckdns.org:8080
VITE_WS_URL=ws://cmscallabration.duckdns.org:5000
EOF
echo "✅ Environment file created"
echo ""

echo "4️⃣ Rebuilding and starting services..."
docker-compose up -d --build
echo ""

echo "5️⃣ Waiting for services to start (30 seconds)..."
sleep 30
echo ""

echo "6️⃣ Checking container status..."
docker-compose ps
echo ""

echo "7️⃣ Testing frontend..."
curl -I http://localhost:3000
echo ""

echo "✅ Done!"
echo ""
echo "🌐 Access your application:"
echo "   http://cmscallabration.duckdns.org:3000"
echo ""
echo "📋 View logs:"
echo "   docker-compose logs -f frontend"
echo ""
echo "🔍 If still blank, check browser console for errors"
