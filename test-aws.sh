#!/bin/bash
# Test script for AWS deployment

echo "=== Stopping containers ==="
docker-compose -f docker-compose.yml -f docker-compose.prod.yml down

echo ""
echo "=== Starting containers ==="
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo ""
echo "=== Waiting 45 seconds for services to initialize ==="
sleep 45

echo ""
echo "=== Container Status ==="
docker-compose -f docker-compose.yml -f docker-compose.prod.yml ps

echo ""
echo "=== Backend Logs (last 30 lines) ==="
docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs backend | tail -30

echo ""
echo "=== Testing API ==="
curl -v http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"test123"}'

echo ""
echo "=== Test Complete ==="
