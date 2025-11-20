#!/bin/bash
set -e

echo "=== CMS AWS Deployment Script ==="
echo ""

# Change to the project directory
cd /home/ec2-user/CMS_Callaberation

# Stop all containers
echo "Stopping all containers..."
docker-compose down -v 2>/dev/null || true

# Remove MySQL volume to ensure fresh initialization
echo "Removing MySQL volume..."
docker volume rm cms_callaberation_mysql_data 2>/dev/null || true

# Pull latest images
echo "Pulling latest code from GitHub..."
git pull origin main

# Build images
echo "Building Docker images..."
docker-compose build --no-cache

# Start MySQL first
echo "Starting MySQL..."
docker-compose up -d mysql

# Wait for MySQL to be fully ready
echo "Waiting 50 seconds for MySQL to initialize..."
sleep 50

# Verify MySQL is accessible
echo "Verifying MySQL connection..."
docker-compose exec -T mysql mysql -ucmsuser -pcmspassword -e "SELECT 'MySQL is ready!' as status;" || {
    echo "ERROR: MySQL is not accessible. Checking logs..."
    docker-compose logs mysql
    exit 1
}

# Start remaining services
echo "Starting backend, PHP server, and frontend..."
docker-compose up -d backend php-server frontend

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Install PHP dependencies
echo "Installing PHP dependencies..."
docker-compose exec -T php-server composer install --no-dev --optimize-autoloader || {
    echo "WARNING: Could not install PHP dependencies, but continuing..."
}

# Show status
echo ""
echo "=== Container Status ==="
docker-compose ps

echo ""
echo "=== Backend Logs (last 20 lines) ==="
docker-compose logs --tail=20 backend

echo ""
echo "=== Deployment Complete ==="
echo "Frontend: http://cmscallabration.duckdns.org:3000"
echo "Backend: http://cmscallabration.duckdns.org:5000"
echo ""
echo "Test credentials:"
echo "  admin@cms.local / admin123"
echo "  editor@cms.local / editor123"
echo ""
echo "To view logs, run: docker-compose logs -f [service-name]"
