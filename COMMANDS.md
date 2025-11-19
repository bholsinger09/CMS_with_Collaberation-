# Development Commands Reference

Quick reference for all available commands in the CMS Collaboration Platform.

## 🎯 Quick Start (Choose One)

### Docker (Recommended)
```bash
docker-compose up -d
```

### Manual Setup
```bash
chmod +x setup.sh && ./setup.sh
```

---

## 📦 Root Level Commands

From the project root directory:

```bash
# Setup
npm run setup                    # Run automated setup script

# Development (separate terminals)
npm run dev:frontend             # Start React dev server
npm run dev:backend              # Start C# backend
npm run dev:php                  # Start PHP server

# Building
npm run build:frontend           # Build React for production
npm run build:backend            # Build C# project

# Docker
npm run docker:up                # Start all containers
npm run docker:down              # Stop all containers
npm run docker:logs              # View container logs
npm run docker:restart           # Restart all containers
```

---

## ⚛️ Frontend Commands

Navigate to `frontend/` directory:

```bash
cd frontend
```

### Development
```bash
npm install                      # Install dependencies
npm run dev                      # Start dev server (http://localhost:3000)
npm run build                    # Build for production
npm run preview                  # Preview production build
npm run lint                     # Lint code
```

### Package Management
```bash
npm install <package>            # Add new package
npm uninstall <package>          # Remove package
npm update                       # Update all packages
npm outdated                     # Check for outdated packages
```

### Environment
```bash
cp .env.example .env             # Create environment file
```

---

## 🔷 Backend (C#) Commands

Navigate to `backend/` directory:

```bash
cd backend
```

### Development
```bash
dotnet restore                   # Restore packages
dotnet build                     # Build project
dotnet run                       # Run application (http://localhost:5000)
dotnet watch run                 # Run with hot reload
```

### Database
```bash
# Entity Framework Core commands
dotnet ef migrations add <name>  # Create new migration
dotnet ef database update        # Apply migrations
dotnet ef database drop          # Drop database
dotnet ef migrations remove      # Remove last migration
```

### Testing
```bash
dotnet test                      # Run tests
dotnet test --logger "console"   # Run with console output
```

### Publishing
```bash
dotnet publish -c Release        # Publish release build
dotnet publish -c Release -o ./publish  # Publish to specific directory
```

### Cleaning
```bash
dotnet clean                     # Clean build artifacts
dotnet restore --force           # Force restore packages
```

---

## 🐘 PHP Server Commands

Navigate to `php-server/` directory:

```bash
cd php-server
```

### Development
```bash
composer install                 # Install dependencies
composer start                   # Start dev server (http://localhost:8080)
php -S localhost:8080 -t public  # Alternative start command
```

### Package Management
```bash
composer require <package>       # Add package
composer remove <package>        # Remove package
composer update                  # Update all packages
composer outdated                # Check outdated packages
composer dump-autoload           # Regenerate autoload files
```

### Testing
```bash
composer test                    # Run PHPUnit tests (if configured)
```

### Environment
```bash
cp .env.example .env             # Create environment file
```

---

## 🗄️ Database Commands

### MySQL CLI
```bash
# Connect to database
mysql -u cmsuser -p cms_collaboration

# Import schema
mysql -u cmsuser -p cms_collaboration < database/init.sql

# Backup database
mysqldump -u cmsuser -p cms_collaboration > backup.sql

# Restore database
mysql -u cmsuser -p cms_collaboration < backup.sql
```

### Docker MySQL
```bash
# Connect to MySQL in Docker
docker-compose exec mysql mysql -u cmsuser -p

# Backup from Docker
docker-compose exec mysql mysqldump -u cmsuser -p cms_collaboration > backup.sql

# Restore to Docker
docker-compose exec -T mysql mysql -u cmsuser -p cms_collaboration < backup.sql
```

---

## 🐳 Docker Commands

### Basic Operations
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d frontend

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Restart services
docker-compose restart

# View logs
docker-compose logs -f
docker-compose logs -f frontend  # Specific service
```

### Container Management
```bash
# List running containers
docker-compose ps

# Execute command in container
docker-compose exec frontend sh
docker-compose exec backend bash
docker-compose exec mysql mysql -u root -p

# View container logs
docker logs cms_react_frontend
docker logs cms_dotnet_backend
docker logs cms_php_server
docker logs cms_mysql
```

### Cleanup
```bash
# Remove stopped containers
docker-compose rm

# Remove all containers and networks
docker-compose down

# Remove everything including volumes
docker-compose down -v

# Prune unused Docker resources
docker system prune -a
```

### Rebuild
```bash
# Rebuild all images
docker-compose build

# Rebuild specific service
docker-compose build frontend

# Rebuild and start
docker-compose up -d --build

# Force recreate containers
docker-compose up -d --force-recreate
```

---

## 🔍 Debugging & Monitoring

### Frontend Debugging
```bash
# Check for TypeScript errors
cd frontend && npx tsc --noEmit

# Analyze bundle size
npm run build && npx vite-bundle-analyzer
```

### Backend Debugging
```bash
# Run with detailed logging
dotnet run --environment Development

# Check for code issues
dotnet format --verify-no-changes
```

### PHP Debugging
```bash
# Check syntax
php -l public/index.php

# Run with error display
php -S localhost:8080 -t public -d display_errors=1
```

### Docker Debugging
```bash
# Check service health
docker-compose ps

# Inspect container
docker inspect cms_react_frontend

# View resource usage
docker stats

# Check networks
docker network ls
docker network inspect cms_network
```

---

## 🧪 Testing Commands

### Frontend Testing
```bash
cd frontend
npm test                         # Run tests
npm run test:watch              # Watch mode
npm run test:coverage           # With coverage
```

### Backend Testing
```bash
cd backend
dotnet test                     # Run all tests
dotnet test --filter TestName   # Run specific test
dotnet test --logger "console;verbosity=detailed"
```

### Integration Testing
```bash
# Start test environment
docker-compose -f docker-compose.test.yml up -d

# Run integration tests
npm run test:integration
```

---

## 📊 Useful One-Liners

### Check All Services
```bash
# Check if all ports are available
lsof -i :3000,5000,8080,3306

# Kill process on port
kill -9 $(lsof -ti:3000)
```

### Quick Database Reset
```bash
# Drop and recreate database
mysql -u root -p -e "DROP DATABASE IF EXISTS cms_collaboration; CREATE DATABASE cms_collaboration;"
mysql -u root -p cms_collaboration < database/init.sql
```

### Full Clean Rebuild
```bash
# Frontend
cd frontend && rm -rf node_modules dist && npm install && cd ..

# Backend
cd backend && dotnet clean && dotnet restore && cd ..

# PHP
cd php-server && rm -rf vendor && composer install && cd ..

# Docker
docker-compose down -v && docker-compose build --no-cache && docker-compose up -d
```

### Check Application Health
```bash
# Frontend
curl http://localhost:3000

# Backend
curl http://localhost:5000/swagger/index.html

# PHP
curl http://localhost:8080/api/content/published

# Database
mysql -u cmsuser -p -e "SELECT COUNT(*) FROM cms_collaboration.Users;"
```

---

## 🚀 Production Deployment

### Frontend Production Build
```bash
cd frontend
npm run build
# Serve dist/ directory with nginx or apache
```

### Backend Production
```bash
cd backend
dotnet publish -c Release -o ./publish
cd publish
dotnet CMSCollaboration.dll
```

### Docker Production
```bash
# Use production compose file
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📝 Notes

- Always run `npm install`, `dotnet restore`, or `composer install` after pulling changes
- Check `.env` files are configured before running services
- Use `docker-compose logs -f` to debug startup issues
- Default credentials: admin@cms.local / admin123

---

**Need Help?**
- Check logs: `docker-compose logs -f [service]`
- Restart service: `docker-compose restart [service]`
- Full restart: `docker-compose down && docker-compose up -d`
- Read documentation in respective README files
