# Quick Start Guide

Get up and running with CMS Collaboration Platform in minutes!

## Prerequisites

- Node.js 18+ ([Download](https://nodejs.org/))
- .NET 8.0 SDK ([Download](https://dotnet.microsoft.com/download))
- PHP 8.1+ ([Download](https://www.php.net/downloads))
- MySQL 8.0+ ([Download](https://dev.mysql.com/downloads/))
- Composer ([Download](https://getcomposer.org/))

## Option 1: Docker (Recommended)

The fastest way to get started:

```bash
# Clone the repository
git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
cd CMS_Callaberation

# Start all services with Docker Compose
docker-compose up -d

# Check status
docker-compose ps
```

Access the application:
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- PHP API: http://localhost:8080
- Swagger Docs: http://localhost:5000/swagger

## Option 2: Manual Setup

### Step 1: Clone Repository
```bash
git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
cd CMS_Callaberation
```

### Step 2: Run Setup Script
```bash
chmod +x setup.sh
./setup.sh
```

The script will:
- Check prerequisites
- Install all dependencies
- Create configuration files
- Set up the database

### Step 3: Configure Services

#### Frontend (.env)
```bash
cd frontend
cp .env.example .env
```

Edit `frontend/.env`:
```env
VITE_API_URL=http://localhost:5000
VITE_PHP_URL=http://localhost:8080
VITE_WS_URL=ws://localhost:5000
```

#### Backend (appsettings.json)
Edit `backend/appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=cms_collaboration;User=cmsuser;Password=cmspassword;"
  },
  "JwtSettings": {
    "SecretKey": "YourSecretKeyHere-ChangeThisInProduction-MinimumLength32Characters"
  }
}
```

#### PHP Server (.env)
```bash
cd php-server
cp .env.example .env
```

Edit `php-server/.env`:
```env
DB_HOST=localhost
DB_DATABASE=cms_collaboration
DB_USERNAME=cmsuser
DB_PASSWORD=cmspassword
```

### Step 4: Initialize Database
```bash
mysql -u root -p < database/init.sql
```

### Step 5: Start Services

Open 3 separate terminal windows:

**Terminal 1 - Frontend:**
```bash
cd frontend
npm run dev
```

**Terminal 2 - C# Backend:**
```bash
cd backend
dotnet run
```

**Terminal 3 - PHP Server:**
```bash
cd php-server
composer start
```

## Default Login Credentials

Once running, log in with:

**Admin Account:**
- Email: `admin@cms.local`
- Password: `admin123`

**Editor Account:**
- Email: `editor@cms.local`
- Password: `password123`

⚠️ **Change these passwords immediately in production!**

## First Steps

1. **Log in** at http://localhost:3000
2. **Create a document** - Click "New Document"
3. **Start writing** - Use the rich text editor
4. **Save draft** - Click "Save Draft"
5. **Collaborate** - Open the same document in another browser tab
6. **Publish** - Click "Publish" when ready

## Testing Collaboration

To test real-time collaboration:

1. Open http://localhost:3000 in two browser windows
2. Log in with different accounts in each window
3. Create or open a document
4. Type in one window and watch it appear in the other!

## Useful Commands

### Development
```bash
# Frontend development with hot reload
npm run dev:frontend

# Backend development with auto-restart
npm run dev:backend

# PHP server
npm run dev:php
```

### Building
```bash
# Build frontend for production
npm run build:frontend

# Build backend
npm run build:backend
```

### Docker
```bash
# Start all services
npm run docker:up

# Stop all services
npm run docker:down

# View logs
npm run docker:logs

# Restart services
npm run docker:restart
```

## Troubleshooting

### Port Already in Use
If ports 3000, 5000, or 8080 are already in use:

**Frontend:** Edit `frontend/vite.config.ts` and change the port
**Backend:** Run with `dotnet run --urls "http://localhost:5050"`
**PHP:** Run with `php -S localhost:8888 -t public`

### Database Connection Failed
- Ensure MySQL is running: `sudo systemctl status mysql` (Linux) or check Activity Monitor (Mac)
- Verify credentials in configuration files
- Check if database exists: `mysql -u root -p -e "SHOW DATABASES;"`

### Module Not Found (Frontend)
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### .NET Restore Failed
```bash
cd backend
dotnet clean
dotnet restore
```

### Composer Install Failed
```bash
cd php-server
rm -rf vendor composer.lock
composer install
```

## Next Steps

- Read the [README.md](README.md) for detailed information
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- See [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
- Explore API docs at http://localhost:5000/swagger

## Getting Help

- **Issues**: https://github.com/bholsinger09/CMS_with_Collaberation-/issues
- **Discussions**: GitHub Discussions
- **Documentation**: Check README files in each service directory

## Production Deployment

For production deployment, see:
- Frontend: [frontend/README.md](frontend/README.md)
- Backend: [backend/README.md](backend/README.md)
- PHP Server: [php-server/README.md](php-server/README.md)

Remember to:
- ✅ Change default passwords
- ✅ Update JWT secret key
- ✅ Enable HTTPS
- ✅ Configure proper CORS
- ✅ Set up monitoring
- ✅ Configure backups

Happy collaborating! 🚀
