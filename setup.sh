#!/bin/bash

# CMS Collaboration Platform - Quick Setup Script
# This script sets up the development environment for all services

set -e

echo "🚀 Setting up CMS Collaboration Platform..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check prerequisites
echo ""
echo "Checking prerequisites..."

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_status "Node.js found: $NODE_VERSION"
else
    print_error "Node.js not found. Please install Node.js 18+"
    exit 1
fi

# Check .NET
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    print_status ".NET SDK found: $DOTNET_VERSION"
else
    print_error ".NET SDK not found. Please install .NET 8.0+"
    exit 1
fi

# Check PHP
if command -v php &> /dev/null; then
    PHP_VERSION=$(php --version | head -n 1)
    print_status "PHP found: $PHP_VERSION"
else
    print_error "PHP not found. Please install PHP 8.1+"
    exit 1
fi

# Check Composer
if command -v composer &> /dev/null; then
    print_status "Composer found"
else
    print_warning "Composer not found. PHP dependencies will not be installed."
fi

# Check MySQL
if command -v mysql &> /dev/null; then
    print_status "MySQL found"
else
    print_warning "MySQL not found. Please ensure MySQL is installed and running."
fi

echo ""
echo "📦 Installing dependencies..."

# Frontend setup
echo ""
echo "Setting up Frontend..."
cd frontend
if [ ! -f ".env" ]; then
    cp .env.example .env
    print_status "Created frontend .env file"
fi
npm install
print_status "Frontend dependencies installed"
cd ..

# Backend setup
echo ""
echo "Setting up Backend..."
cd backend
dotnet restore
print_status "Backend dependencies restored"
cd ..

# PHP Server setup
echo ""
echo "Setting up PHP Server..."
cd php-server
if [ ! -f ".env" ]; then
    cp .env.example .env
    print_status "Created PHP server .env file"
fi
if command -v composer &> /dev/null; then
    composer install
    print_status "PHP dependencies installed"
fi
mkdir -p public/uploads
chmod 755 public/uploads
print_status "Created uploads directory"
cd ..

# Database setup
echo ""
echo "🗄️  Setting up Database..."
print_warning "Please ensure MySQL is running and accessible"
echo ""
read -p "Do you want to initialize the database now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter MySQL username [root]: " DB_USER
    DB_USER=${DB_USER:-root}
    read -sp "Enter MySQL password: " DB_PASS
    echo ""
    
    if mysql -u "$DB_USER" -p"$DB_PASS" < database/init.sql 2>/dev/null; then
        print_status "Database initialized successfully"
    else
        print_error "Failed to initialize database. You can run it manually later."
    fi
else
    print_warning "Skipping database initialization. Run manually: mysql -u root -p < database/init.sql"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Update configuration files with your settings:"
echo "   - frontend/.env"
echo "   - backend/appsettings.json"
echo "   - php-server/.env"
echo ""
echo "2. Start the services:"
echo "   - Frontend:   cd frontend && npm run dev"
echo "   - Backend:    cd backend && dotnet run"
echo "   - PHP Server: cd php-server && composer start"
echo ""
echo "3. Or use Docker Compose:"
echo "   docker-compose up -d"
echo ""
echo "4. Access the application:"
echo "   - Frontend: http://localhost:3000"
echo "   - Backend API: http://localhost:5000"
echo "   - PHP API: http://localhost:8080"
echo "   - Swagger: http://localhost:5000/swagger"
echo ""
echo "5. Default login credentials:"
echo "   - Admin: admin@cms.local / admin123"
echo "   - Editor: editor@cms.local / password123"
echo ""
print_warning "Remember to change default passwords in production!"
echo ""
