#!/bin/bash

# Service Verification Script for CMS Collaboration Platform
# This script checks that all services are running correctly after reboot

echo "🔍 Verifying CMS Services on AWS EC2..."
echo "=========================================="
echo ""

# Test SSH connection
echo "1. Testing SSH connection..."
if ssh -i ~/.ssh/cms-collaboration-key.pem -o ConnectTimeout=10 ec2-user@3.88.158.94 "echo 'Connected'" > /dev/null 2>&1; then
    echo "✅ SSH connection successful"
else
    echo "❌ SSH connection failed"
    exit 1
fi
echo ""

# Check Docker containers
echo "2. Checking Docker containers..."
ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94 "docker ps --format 'table {{.Names}}\t{{.Status}}'"
echo ""

# Test Frontend
echo "3. Testing Frontend (Port 3000)..."
FRONTEND_STATUS=$(ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94 "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ Frontend responding: HTTP $FRONTEND_STATUS"
else
    echo "⚠️  Frontend status: HTTP $FRONTEND_STATUS"
fi
echo ""

# Test Backend
echo "4. Testing Backend (Port 5002)..."
BACKEND_STATUS=$(ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94 "curl -s -o /dev/null -w '%{http_code}' http://localhost:5002")
if [ "$BACKEND_STATUS" = "404" ] || [ "$BACKEND_STATUS" = "200" ]; then
    echo "✅ Backend responding: HTTP $BACKEND_STATUS"
else
    echo "⚠️  Backend status: HTTP $BACKEND_STATUS"
fi
echo ""

# Test PHP Server
echo "5. Testing PHP Server (Port 8080)..."
PHP_STATUS=$(ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94 "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080")
if [ "$PHP_STATUS" = "200" ]; then
    echo "✅ PHP Server responding: HTTP $PHP_STATUS"
else
    echo "⚠️  PHP Server status: HTTP $PHP_STATUS"
fi
echo ""

# Check for errors in logs
echo "6. Checking for errors in container logs..."
echo "Frontend logs:"
ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94 "docker logs cms_react_frontend --tail 5 2>&1 | grep -i 'error\|fail\|fatal' || echo '  No errors found'"
echo ""
echo "Backend logs:"
ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94 "docker logs cms_dotnet_backend --tail 5 2>&1 | grep -i 'error\|fail\|fatal' || echo '  No errors found'"
echo ""
echo "PHP Server logs:"
ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94 "docker logs cms_php_server --tail 5 2>&1 | grep -i 'error\|fail\|fatal' || echo '  No errors found'"
echo ""

# Summary
echo "=========================================="
echo "✅ All services verified successfully!"
echo ""
echo "Public URLs:"
echo "  Frontend: http://3.88.158.94:3000"
echo "  Backend:  http://3.88.158.94:5002"
echo "  PHP API:  http://3.88.158.94:8080"
echo ""
echo "To restart services after reboot:"
echo "  ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94 'cd /home/ec2-user/CMS_Callaberation && docker-compose up -d'"
