# Backend Setup Guide

## Prerequisites

- .NET 8.0 SDK
- MySQL 8.0+

## Installation

1. Restore packages:
```bash
dotnet restore
```

2. Update database connection string in `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=cms_collaboration;User=cmsuser;Password=cmspassword;"
  }
}
```

3. Run database migrations:
```bash
dotnet ef database update
```

Or manually run the `database/init.sql` script.

## Development

Run the application:
```bash
dotnet run
```

The API will be available at:
- HTTP: http://localhost:5000
- HTTPS: https://localhost:5001
- Swagger: http://localhost:5000/swagger

## Build

Build the project:
```bash
dotnet build
```

Publish for production:
```bash
dotnet publish -c Release -o ./publish
```

## Features

- **RESTful API**: Standard HTTP endpoints for CRUD operations
- **SignalR Hub**: Real-time WebSocket communication
- **JWT Authentication**: Secure token-based auth
- **Entity Framework Core**: ORM for database operations
- **Swagger/OpenAPI**: Interactive API documentation
- **CORS Support**: Configured for frontend access

## Project Structure

```
backend/
├── Controllers/        # API controllers
│   ├── AuthController.cs
│   ├── ContentController.cs
│   └── DashboardController.cs
├── Data/              # Database context
│   └── ApplicationDbContext.cs
├── Hubs/              # SignalR hubs
│   └── CollaborationHub.cs
├── Models/            # Domain models
│   ├── User.cs
│   ├── Content.cs
│   ├── ContentVersion.cs
│   └── CollaborationSession.cs
├── Services/          # Business logic
│   ├── AuthService.cs
│   └── ContentService.cs
└── Program.cs         # Application entry point
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration

### Content
- `GET /api/content` - List all content
- `GET /api/content/{id}` - Get specific content
- `POST /api/content` - Create new content
- `PUT /api/content/{id}` - Update content
- `DELETE /api/content/{id}` - Delete content
- `PUT /api/content/{id}/publish` - Publish content
- `GET /api/content/{id}/versions` - Get version history

### Dashboard
- `GET /api/dashboard/stats` - Dashboard statistics
- `GET /api/dashboard/recent-activities` - Recent activity feed

### SignalR Hub
- `/collaborationHub` - WebSocket endpoint for real-time collaboration

## SignalR Methods

### Client → Server
- `JoinDocument(documentId, userId)` - Join a document editing session
- `LeaveDocument(documentId, userId)` - Leave a document
- `UpdateContent(content)` - Broadcast content changes
- `UpdateCursor(position)` - Share cursor position

### Server → Client
- `UserJoined(user)` - Notification when user joins
- `UserLeft(userId)` - Notification when user leaves
- `ContentChanged(content, userId)` - Content update from another user
- `CursorMoved(userId, position)` - Cursor position update

## Configuration

### JWT Settings
Update in `appsettings.json`:
```json
{
  "JwtSettings": {
    "SecretKey": "YourSecretKeyHere-ChangeThisInProduction",
    "Issuer": "CMSCollaboration",
    "Audience": "CMSCollaborationUsers",
    "ExpirationMinutes": 1440
  }
}
```

⚠️ **Important**: Change the SecretKey in production!

## Troubleshooting

### Database connection errors
- Verify MySQL is running
- Check connection string
- Ensure database and user exist

### Port conflicts
Update `launchSettings.json` or use:
```bash
dotnet run --urls "http://localhost:5050"
```
