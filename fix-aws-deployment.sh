#!/bin/bash
echo "=== CMS Deployment Fix Script ==="
echo "Ensuring proper container startup order..."

cd ~/CMS_with_Collaberation-

# Stop everything
echo "Stopping all containers..."
docker-compose down

# Start MySQL first and wait for it to be ready
echo "Starting MySQL..."
docker-compose up -d mysql

echo "Waiting for MySQL to be fully ready (30 seconds)..."
sleep 10

# Poll MySQL until it's ready
for i in {1..20}; do
    if docker exec cms_mysql mysqladmin ping -ucmsuser -pcmspassword --silent 2>/dev/null; then
        echo "✓ MySQL is ready!"
        break
    fi
    echo "Waiting for MySQL... ($i/20)"
    sleep 2
done

# Update passwords immediately
echo "Updating user passwords..."
docker exec -i cms_mysql mysql -ucmsuser -pcmspassword cms_collaboration << 'EOF'
UPDATE Users SET PasswordHash='JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=' WHERE Username='admin';
UPDATE Users SET PasswordHash='715aH7lQVeDlbMz5ikHnhKEywU5/bhuiRDAvDnKym68=' WHERE Username='editor';
SELECT 'Passwords updated' as Status;
EOF

# Now start the other services
echo "Starting backend, PHP, and frontend..."
docker-compose up -d backend php-server frontend

echo "Waiting for backend to start (10 seconds)..."
sleep 10

# Install PHP dependencies
echo "Installing PHP dependencies..."
docker exec cms_php_server composer install --no-dev --optimize-autoloader 2>&1 | tail -5

# Test backend
echo ""
echo "=== Testing Backend ==="
curl -s -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser8","email":"test8@example.com","password":"test123"}' | head -5

echo ""
echo ""
echo "=== Container Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✅ Setup complete!"
echo "Access your application at: http://cmscallabration.duckdns.org:3000"
echo "Login: admin@cms.local / admin123"
