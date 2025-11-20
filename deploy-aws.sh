#!/bin/bash

echo "=== AWS Server Deployment Fix Script ==="
echo ""
echo "This script will:"
echo "1. Update docker-compose.yml with production URLs"
echo "2. Rebuild containers with correct configuration"
echo "3. Update database passwords"
echo ""
read -p "Press Enter to continue..."

cd ~/CMS_with_Collaberation-

# Backup original docker-compose.yml
cp docker-compose.yml docker-compose.yml.backup

# Update frontend environment variables for production
cat > docker-compose.yml << 'EOF'
services:
  mysql:
    image: mysql:8.0
    container_name: cms_mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: cms_collaboration
      MYSQL_USER: cmsuser
      MYSQL_PASSWORD: cmspassword
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - cms_network

  php-server:
    build:
      context: ./php-server
      dockerfile: Dockerfile
    container_name: cms_php_server
    ports:
      - "8080:80"
    volumes:
      - ./php-server:/var/www/html
    depends_on:
      - mysql
    environment:
      DB_HOST: mysql
      DB_DATABASE: cms_collaboration
      DB_USERNAME: cmsuser
      DB_PASSWORD: cmspassword
    networks:
      - cms_network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: cms_dotnet_backend
    ports:
      - "5000:8080"
    depends_on:
      - mysql
    environment:
      ASPNETCORE_ENVIRONMENT: Development
      ASPNETCORE_HTTP_PORTS: "8080"
      ConnectionStrings__DefaultConnection: "Server=mysql;Database=cms_collaboration;User=cmsuser;Password=cmspassword;"
    networks:
      - cms_network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: cms_react_frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - VITE_API_URL=http://cmscallabration.duckdns.org:5000
      - VITE_PHP_URL=http://cmscallabration.duckdns.org:8080
      - VITE_WS_URL=ws://cmscallabration.duckdns.org:5000
    depends_on:
      - backend
      - php-server
    networks:
      - cms_network

networks:
  cms_network:
    driver: bridge

volumes:
  mysql_data:
EOF

echo "✓ Updated docker-compose.yml with production URLs"
echo ""

# Stop existing containers
echo "Stopping containers..."
docker-compose down

# Rebuild and start
echo "Building and starting containers..."
docker-compose up -d --build

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
sleep 10

# Update database passwords
echo "Updating database passwords..."
cat > /tmp/update_passwords.sql << 'SQLEOF'
UPDATE Users SET PasswordHash='JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=' WHERE Username='admin';
UPDATE Users SET PasswordHash='715aH7lQVeDlbMz5ikHnhKEywU5/bhuiRDAvDnKym68=' WHERE Username='editor';
SELECT Username, Email, 'Password Updated' as Status FROM Users WHERE Username IN ('admin', 'editor');
SQLEOF

docker exec -i cms_mysql mysql -ucmsuser -pcmspassword cms_collaboration < /tmp/update_passwords.sql 2>&1 | grep -v Warning
rm /tmp/update_passwords.sql

# Install PHP dependencies
echo "Installing PHP dependencies..."
docker exec cms_php_server composer install --no-dev --optimize-autoloader

echo ""
echo "=== Deployment Status ==="
docker ps --filter "name=cms" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=== Testing Endpoints ==="
echo -n "Frontend (port 3000): "
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 && echo " ✓"

echo -n "Backend (port 5000): "
curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/swagger && echo " ✓"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Access your application at:"
echo "  http://cmscallabration.duckdns.org:3000"
echo ""
echo "Login with:"
echo "  Email: admin@cms.local"
echo "  Password: admin123"
