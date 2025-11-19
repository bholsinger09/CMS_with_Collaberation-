# CMS Collaboration Platform - Architecture Overview

## System Architecture

The CMS Collaboration Platform is built using a modern, multi-tier architecture with three main components:

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                            │
│                 React + TypeScript + Vite                   │
│              TailwindCSS + React Query                      │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   │ HTTP/REST + WebSocket (SignalR)
                   │
┌──────────────────┴──────────────────────────────────────────┐
│                      Backend Services                        │
├──────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐      ┌──────────────────────┐     │
│  │   C# Backend API    │      │   PHP Server         │     │
│  │   ASP.NET Core      │      │   Slim Framework     │     │
│  │   SignalR Hub       │      │   Content Export     │     │
│  │   JWT Auth          │      │   Media Management   │     │
│  └─────────┬───────────┘      └──────────┬───────────┘     │
│            │                               │                 │
│            └───────────────┬───────────────┘                │
└────────────────────────────┼─────────────────────────────────┘
                             │
                             │ MySQL Connection
                             │
┌────────────────────────────┴─────────────────────────────────┐
│                      Database Layer                          │
│                        MySQL 8.0+                            │
│   Users | Contents | Versions | Sessions | Tags | Media     │
└──────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend Layer
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **Styling**: TailwindCSS
- **State Management**: Zustand
- **Data Fetching**: TanStack React Query
- **Real-time**: SignalR Client
- **Rich Text Editor**: React Quill
- **Routing**: React Router v6

### C# Backend Layer
- **Framework**: ASP.NET Core 8.0
- **Real-time**: SignalR
- **ORM**: Entity Framework Core
- **Database Provider**: Pomelo MySQL
- **Authentication**: JWT Bearer
- **API Documentation**: Swagger/OpenAPI

### PHP Server Layer
- **Framework**: Slim Framework 4
- **DI Container**: PHP-DI
- **Database**: PDO
- **Standards**: PSR-7, PSR-15

### Database
- **RDBMS**: MySQL 8.0
- **Charset**: UTF8MB4 (full Unicode support)
- **Engine**: InnoDB (transactions, foreign keys)

## Core Features

### 1. Real-time Collaboration
- Multiple users can edit the same document simultaneously
- Live cursor position tracking
- User presence indicators
- Automatic conflict resolution
- WebSocket-based communication via SignalR

**Flow**:
```
User A opens document → Joins SignalR room → Updates content
     ↓
SignalR Hub broadcasts to room
     ↓
User B receives update → UI updates automatically
```

### 2. Authentication & Authorization
- JWT-based authentication
- Role-based access control (Admin, Editor, Viewer)
- Secure password hashing (SHA256)
- Token expiration and refresh

**Flow**:
```
Login → Validate credentials → Generate JWT → Store in frontend
     ↓
Subsequent requests include JWT in Authorization header
     ↓
Backend validates JWT → Extracts user info → Processes request
```

### 3. Content Management
- Create, Read, Update, Delete operations
- Draft and Published states
- Rich text editing with Quill
- Version control and history
- Content export (JSON, HTML, Markdown)

### 4. Version Control
- Automatic versioning on every save
- Full change history
- Version comparison (future enhancement)
- Rollback capability
- Change descriptions

### 5. Media Management
- File upload support
- Image handling
- Media library
- Association with content

## Data Flow

### Content Creation Flow
```
1. User creates content in React editor
2. Frontend sends POST to C# API
3. C# API validates and saves to database
4. Initial version created automatically
5. Response returned with content ID
6. Frontend navigates to editor with new ID
```

### Real-time Collaboration Flow
```
1. User A opens document
   → Frontend connects to SignalR Hub
   → Joins document-specific group
   
2. User A makes changes
   → Frontend sends UpdateContent to Hub
   → Hub broadcasts to all users in group
   
3. User B receives update
   → Frontend applies changes to editor
   → Cursor positions synchronized
```

### Content Publishing Flow
```
1. Editor completes content
2. Clicks "Publish" button
3. Frontend sends PUT to /api/content/{id}/publish
4. C# API updates status to "published"
5. Content becomes available via PHP API
6. Public can access via /api/content/published
```

## Database Schema

### Core Tables

**Users**
- Authentication and user management
- Stores hashed passwords
- Tracks login activity

**Contents**
- Main content storage
- Links to author (User)
- Status tracking (draft/published)

**ContentVersions**
- Version history
- Links to content and creator
- Stores complete content snapshot

**CollaborationSessions**
- Active editing sessions
- Tracks SignalR connections
- User presence management

**Tags**
- Content categorization
- Many-to-many with contents

**Media**
- File metadata
- Upload tracking

## Security Considerations

### Authentication
- JWT tokens with expiration
- Secure password hashing
- HTTPS recommended for production
- Token refresh mechanism

### Authorization
- Role-based access control
- Endpoint protection with [Authorize] attribute
- Resource ownership validation

### Data Validation
- Input sanitization
- SQL injection prevention (parameterized queries)
- XSS protection (React escapes by default)
- File upload restrictions

### CORS
- Configured for specific origins
- Credentials allowed for authentication

## Scalability

### Horizontal Scaling
- Frontend: Static files, CDN-ready
- C# Backend: Stateless API, load balancer compatible
- PHP Server: Stateless, easily replicated
- Database: Master-slave replication

### Performance Optimization
- Database indexing on frequently queried fields
- Query optimization with EF Core
- Caching strategy (Redis recommended)
- Asset optimization (minification, compression)

## Deployment

### Docker Deployment
All services containerized with Docker Compose:
```
docker-compose up -d
```

Services:
- MySQL (port 3306)
- C# Backend (port 5000)
- PHP Server (port 8080)
- React Frontend (port 3000)

### Manual Deployment

**Frontend**: Build and serve static files
```bash
npm run build
# Serve dist/ with nginx or apache
```

**C# Backend**: Publish and run
```bash
dotnet publish -c Release
dotnet CMSCollaboration.dll
```

**PHP Server**: Configure web server
```bash
# Apache or Nginx with PHP-FPM
```

## Monitoring & Logging

### Logging
- C# Backend: Built-in ILogger
- PHP: Monolog
- Frontend: Console logging (production: external service)

### Health Checks
- C# API: /health endpoint (recommended)
- Database connection monitoring
- SignalR connection status

## Future Enhancements

1. **Advanced Collaboration**
   - Inline comments
   - Suggested edits
   - Change tracking

2. **Enhanced Security**
   - OAuth2 integration
   - Two-factor authentication
   - Rate limiting

3. **Performance**
   - Redis caching
   - CDN integration
   - Database sharding

4. **Features**
   - Search functionality
   - Advanced permissions
   - Workflow automation
   - Email notifications
   - Audit logging

## API Reference

Detailed API documentation available at:
- Swagger UI: http://localhost:5000/swagger
- API endpoints documented in each service's README

## Troubleshooting

Common issues and solutions documented in:
- Frontend README
- Backend README
- PHP Server README
- Database README

## Support

- GitHub Issues: https://github.com/bholsinger09/CMS_with_Collaberation-/issues
- Documentation: Project README files
- Contributing: See CONTRIBUTING.md
