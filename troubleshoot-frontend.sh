#!/bin/bash

# Frontend Troubleshooting Script for AWS Instance
# Run this on your EC2 instance

echo "🔍 CMS Collaboration - Frontend Diagnostics"
echo "============================================"
echo ""

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: Not in project directory"
    echo "Run: cd ~/CMS_with_Collaberation-"
    exit 1
fi

echo "1️⃣ Checking Docker containers..."
docker-compose ps
echo ""

echo "2️⃣ Frontend container logs (last 50 lines)..."
docker-compose logs --tail=50 frontend
echo ""

echo "3️⃣ Checking if frontend is responding..."
curl -I http://localhost:3000 2>&1
echo ""

echo "4️⃣ Checking environment variables..."
docker-compose exec frontend env | grep VITE
echo ""

echo "5️⃣ Checking if dist folder exists..."
docker-compose exec frontend ls -la /app/dist 2>&1 || echo "Dist folder not found"
echo ""

echo "6️⃣ Checking network connectivity..."
docker-compose exec frontend ping -c 2 backend 2>&1 || echo "Cannot reach backend"
echo ""

echo "📊 Summary"
echo "=========="
echo ""
echo "Common issues:"
echo "1. Frontend not built - Need to rebuild: docker-compose up -d --build frontend"
echo "2. Wrong environment variables - Check frontend/.env"
echo "3. Port conflicts - Check if port 3000 is available"
echo "4. CORS issues - Check browser console"
echo ""
echo "Quick fixes:"
echo ""
echo "# Rebuild frontend"
echo "docker-compose down"
echo "docker-compose up -d --build frontend"
echo ""
echo "# View live logs"
echo "docker-compose logs -f frontend"
echo ""
echo "# Restart all services"
echo "docker-compose restart"
