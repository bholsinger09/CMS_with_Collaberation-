# Real-Time CMS Collaboration Platform

A comprehensive content management system with real-time collaboration features, built with React, C#, and PHP.

## Architecture

- **Frontend**: React with TypeScript, Socket.io for real-time updates
- **Backend API**: ASP.NET Core with SignalR for WebSocket connections
- **PHP Server**: Content management and database operations
- **Database**: MySQL for data persistence
- **Real-time**: SignalR and WebSocket for collaborative editing

## Features

- ✅ Real-time collaborative editing
- ✅ User authentication and authorization
- ✅ Content versioning and history
- ✅ Multi-user presence indicators
- ✅ Live cursor tracking
- ✅ Content publishing workflow
- ✅ Role-based access control

## Project Structure

```
.
├── frontend/          # React TypeScript application
├── backend/           # C# ASP.NET Core Web API
├── php-server/        # PHP content management server
├── database/          # Database schemas and migrations
└── docker/            # Docker configuration files
```

## Getting Started

### Prerequisites

- Node.js 18+
- .NET 8.0 SDK
- PHP 8.1+
- MySQL 8.0+
- Docker & Docker Compose (optional)

### Quick Start with Docker

```bash
docker-compose up -d
```

### Manual Setup

#### Frontend
```bash
cd frontend
npm install
npm start
```

#### C# Backend
```bash
cd backend
dotnet restore
dotnet run
```

#### PHP Server
```bash
cd php-server
composer install
php -S localhost:8080
```

## Configuration

### Environment Variables

Create `.env` files in each service directory:

- `frontend/.env`
- `backend/appsettings.Development.json`
- `php-server/.env`

See respective directories for configuration templates.

## API Documentation

- **C# API**: http://localhost:5000/swagger
- **PHP API**: http://localhost:8080/api/docs

## Development

### Frontend Development
- Uses Vite for fast HMR
- TailwindCSS for styling
- React Query for data fetching
- Socket.io client for real-time updates

### Backend Development
- SignalR hubs for real-time communication
- Entity Framework Core for ORM
- JWT authentication
- Swagger for API documentation

### PHP Development
- Laravel or Slim framework
- PDO for database access
- RESTful API design

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License
