#!/bin/bash

# Deployment Verification Script
# This script verifies that all services are running correctly on AWS

echo "=== CMS Collaboration Deployment Verification ==="
echo ""

# SSH details
SSH_KEY="~/.ssh/cms-collaboration-key.pem"
SSH_HOST="ec2-user@3.88.158.94"
PROJECT_DIR="/home/ec2-user/CMS_Callaberation"

echo "1. Checking container status..."
ssh -i $SSH_KEY $SSH_HOST "cd $PROJECT_DIR && docker-compose ps"
echo ""

echo "2. Testing Frontend (Port 3000)..."
FRONTEND_STATUS=$(ssh -i $SSH_KEY $SSH_HOST "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✓ Frontend is responding (HTTP $FRONTEND_STATUS)"
else
    echo "✗ Frontend issue (HTTP $FRONTEND_STATUS)"
fi
echo ""

echo "3. Testing PHP Server (Port 8080)..."
PHP_STATUS=$(ssh -i $SSH_KEY $SSH_HOST "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080")
if [ "$PHP_STATUS" = "200" ]; then
    echo "✓ PHP Server is responding (HTTP $PHP_STATUS)"
else
    echo "✗ PHP Server issue (HTTP $PHP_STATUS)"
fi
echo ""

echo "4. Testing .NET Backend (Port 5002)..."
BACKEND_STATUS=$(ssh -i $SSH_KEY $SSH_HOST "curl -s -o /dev/null -w '%{http_code}' http://localhost:5002")
if [ "$BACKEND_STATUS" = "200" ] || [ "$BACKEND_STATUS" = "404" ]; then
    echo "✓ Backend is responding (HTTP $BACKEND_STATUS)"
else
    echo "✗ Backend issue (HTTP $BACKEND_STATUS)"
fi
echo ""

echo "5. Testing MySQL (Port 3306)..."
MYSQL_STATUS=$(ssh -i $SSH_KEY $SSH_HOST "docker exec cms_mysql mysqladmin -ucmsuser -pcmspassword ping 2>/dev/null")
if [[ "$MYSQL_STATUS" == *"alive"* ]]; then
    echo "✓ MySQL is responding"
else
    echo "✗ MySQL issue"
fi
echo ""

echo "6. Checking Frontend Logs for Errors..."
FRONTEND_ERRORS=$(ssh -i $SSH_KEY $SSH_HOST "docker logs cms_react_frontend 2>&1 | grep -i error | wc -l")
echo "Frontend error count: $FRONTEND_ERRORS"
echo ""

echo "7. Checking PHP Server Logs for Composer Issues..."
PHP_ERRORS=$(ssh -i $SSH_KEY $SSH_HOST "docker logs cms_php_server 2>&1 | grep -iE '(composer|dependency)' | head -5")
if [ -z "$PHP_ERRORS" ]; then
    echo "✓ No PHP dependency issues found"
else
    echo "PHP dependency messages:"
    echo "$PHP_ERRORS"
fi
echo ""

echo "=== Verification Complete ==="
echo ""
echo "Public URLs:"
echo "Frontend: http://3.88.158.94:3000"
echo "PHP Server: http://3.88.158.94:8080"
echo "Backend API: http://3.88.158.94:5002"
