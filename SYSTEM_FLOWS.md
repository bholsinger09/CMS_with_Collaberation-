# System Flow Diagrams

## User Authentication Flow

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │
       │ 1. Enter credentials
       ↓
┌─────────────────────┐
│  Login Component    │
│  (React)            │
└──────┬──────────────┘
       │
       │ 2. POST /api/auth/login
       ↓
┌─────────────────────┐
│  Auth Controller    │
│  (C# Backend)       │
└──────┬──────────────┘
       │
       │ 3. Validate credentials
       ↓
┌─────────────────────┐
│  Auth Service       │
│  (C#)               │
└──────┬──────────────┘
       │
       │ 4. Query database
       ↓
┌─────────────────────┐
│  MySQL Database     │
└──────┬──────────────┘
       │
       │ 5. User data
       ↓
┌─────────────────────┐
│  Generate JWT       │
│  Token              │
└──────┬──────────────┘
       │
       │ 6. Return token + user info
       ↓
┌─────────────────────┐
│  Store in Zustand   │
│  + localStorage     │
└──────┬──────────────┘
       │
       │ 7. Redirect to Dashboard
       ↓
┌─────────────────────┐
│  Authenticated      │
│  User Session       │
└─────────────────────┘
```

## Real-time Collaboration Flow

```
┌──────────────┐                    ┌──────────────┐
│   User A     │                    │   User B     │
└──────┬───────┘                    └──────┬───────┘
       │                                   │
       │ 1. Open document                  │
       │                                   │
       ↓                                   ↓
┌──────────────────────┐          ┌──────────────────────┐
│  Editor Component    │          │  Editor Component    │
│  (React)             │          │  (React)             │
└──────┬───────────────┘          └──────┬───────────────┘
       │                                   │
       │ 2. Connect to SignalR Hub         │
       │                                   │
       └─────────────┬─────────────────────┘
                     │
                     ↓
          ┌─────────────────────┐
          │  SignalR Hub        │
          │  (C# Backend)       │
          └──────────┬──────────┘
                     │
                     │ 3. Join document group
                     ↓
          ┌─────────────────────┐
          │  Collaboration      │
          │  Session Created    │
          └──────────┬──────────┘
                     │
       ┌─────────────┴─────────────┐
       │                           │
       ↓                           ↓
┌──────────────┐            ┌──────────────┐
│   User A     │            │   User B     │
│  Notified    │            │  Notified    │
└──────┬───────┘            └──────┬───────┘
       │                           │
       │ 4. User A types           │
       │                           │
       ↓                           │
┌──────────────────────┐           │
│  UpdateContent()     │           │
│  SignalR Method      │           │
└──────┬───────────────┘           │
       │                           │
       │ 5. Broadcast to group     │
       │                           │
       └──────────┬────────────────┘
                  │
                  │ 6. ContentChanged event
                  │
                  ↓
          ┌──────────────────┐
          │   User B receives│
          │   updates and    │
          │   sees changes   │
          └──────────────────┘
```

## Content Creation & Publishing Flow

```
┌─────────────┐
│   Editor    │
│   (User)    │
└──────┬──────┘
       │
       │ 1. Create new content
       ↓
┌─────────────────────┐
│  Editor Page        │
│  (React)            │
└──────┬──────────────┘
       │
       │ 2. Type content using Quill
       │
       │ 3. Click "Save Draft"
       ↓
┌─────────────────────┐
│  POST /api/content  │
└──────┬──────────────┘
       │
       ↓
┌─────────────────────┐
│  Content Controller │
│  (C# Backend)       │
└──────┬──────────────┘
       │
       │ 4. Validate & process
       ↓
┌─────────────────────┐
│  Content Service    │
└──────┬──────────────┘
       │
       │ 5. Create content record
       │
       ↓
┌─────────────────────┐
│  MySQL Database     │
│  - Contents table   │
│  - ContentVersions  │
└──────┬──────────────┘
       │
       │ 6. Return created content
       ↓
┌─────────────────────┐
│  Frontend receives  │
│  content ID         │
└──────┬──────────────┘
       │
       │ 7. User continues editing
       │
       │ 8. Click "Publish"
       ↓
┌─────────────────────────┐
│  PUT /api/content/{id}  │
│  /publish               │
└──────┬──────────────────┘
       │
       ↓
┌─────────────────────┐
│  Update status to   │
│  "published"        │
│  Set PublishedAt    │
└──────┬──────────────┘
       │
       ↓
┌─────────────────────┐
│  Content now        │
│  available via      │
│  PHP API            │
└─────────────────────┘
       │
       ↓
┌─────────────────────┐
│  GET /api/content/  │
│  published          │
│  (PHP Server)       │
└─────────────────────┘
```

## Media Upload Flow

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │
       │ 1. Select file
       ↓
┌─────────────────────┐
│  File Input         │
│  (React)            │
└──────┬──────────────┘
       │
       │ 2. FormData with file
       ↓
┌─────────────────────┐
│  POST /api/media/   │
│  upload             │
│  (PHP Server)       │
└──────┬──────────────┘
       │
       │ 3. Validate file
       ↓
┌─────────────────────┐
│  Media Controller   │
│  (PHP)              │
└──────┬──────────────┘
       │
       │ 4. Move to uploads/
       ↓
┌─────────────────────┐
│  File System        │
│  /public/uploads/   │
└──────┬──────────────┘
       │
       │ 5. Save metadata
       ↓
┌─────────────────────┐
│  MySQL Database     │
│  Media table        │
└──────┬──────────────┘
       │
       │ 6. Return file URL
       ↓
┌─────────────────────┐
│  Insert into        │
│  editor content     │
└─────────────────────┘
```

## Version Control Flow

```
┌─────────────┐
│   User      │
│   saves     │
│   content   │
└──────┬──────┘
       │
       │ Content update
       ↓
┌─────────────────────┐
│  Content Service    │
│  UpdateContentAsync │
└──────┬──────────────┘
       │
       │ 1. Save content
       ↓
┌─────────────────────┐
│  Contents table     │
│  (updated)          │
└──────┬──────────────┘
       │
       │ 2. Trigger version creation
       ↓
┌─────────────────────┐
│  CreateVersionAsync │
└──────┬──────────────┘
       │
       │ 3. Get last version number
       ↓
┌─────────────────────┐
│  Query last version │
└──────┬──────────────┘
       │
       │ 4. Increment version
       │    Create new record
       ↓
┌─────────────────────┐
│  ContentVersions    │
│  table              │
│  - Version N+1      │
│  - Full content     │
│  - Creator ID       │
│  - Timestamp        │
│  - Description      │
└─────────────────────┘
       │
       ↓
┌─────────────────────┐
│  Version history    │
│  maintained         │
│  (reversible)       │
└─────────────────────┘
```

## Data Export Flow

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │
       │ 1. Request export
       ↓
┌─────────────────────┐
│  POST /api/content/ │
│  {id}/export        │
│  format: "html"     │
└──────┬──────────────┘
       │
       ↓
┌─────────────────────┐
│  Content Controller │
│  (PHP)              │
└──────┬──────────────┘
       │
       │ 2. Fetch content
       ↓
┌─────────────────────┐
│  MySQL Database     │
└──────┬──────────────┘
       │
       │ 3. Content data
       ↓
┌─────────────────────┐
│  Format converter   │
│  - HTML generator   │
│  - MD converter     │
│  - JSON formatter   │
└──────┬──────────────┘
       │
       │ 4. Generated output
       ↓
┌─────────────────────┐
│  Response with      │
│  Content-Disposition│
│  attachment         │
└──────┬──────────────┘
       │
       │ 5. File download
       ↓
┌─────────────────────┐
│  User receives file │
│  article.html       │
└─────────────────────┘
```

## System Architecture Overview

```
                    ┌─────────────────────────────┐
                    │        Internet             │
                    └──────────────┬──────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │    Load Balancer (Optional) │
                    └──────────────┬──────────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
        ↓                          ↓                          ↓
┌───────────────┐          ┌───────────────┐        ┌───────────────┐
│   Frontend    │          │  C# Backend   │        │  PHP Server   │
│   (React)     │◄────────►│  (ASP.NET)    │◄──────►│  (Slim)       │
│   Port 3000   │ SignalR  │  Port 5000    │        │  Port 8080    │
└───────────────┘ WebSocket└───────┬───────┘        └───────┬───────┘
                                   │                        │
                                   │                        │
                    ┌──────────────┴────────────────────────┘
                    │
                    ↓
            ┌───────────────┐
            │    MySQL      │
            │   Database    │
            │   Port 3306   │
            └───────────────┘
```

## Request/Response Cycle

```
User Action (Browser)
      ↓
React Component
      ↓
API Call (axios/fetch)
      ↓
Network Request
      ↓
[C# or PHP Server]
      ↓
Controller/Handler
      ↓
Service Layer
      ↓
Database Query
      ↓
MySQL Database
      ↓
Database Result
      ↓
Service Processing
      ↓
JSON Response
      ↓
Network Response
      ↓
React Query Cache
      ↓
State Update (Zustand)
      ↓
Component Re-render
      ↓
User Sees Updated UI
```

---

These diagrams illustrate the complete system flow and interactions between all components of the CMS Collaboration Platform.
