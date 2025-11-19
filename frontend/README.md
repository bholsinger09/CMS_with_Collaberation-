# Frontend Setup Guide

## Prerequisites

- Node.js 18+
- npm or yarn

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create environment file:
```bash
cp .env.example .env
```

3. Update `.env` with your configuration:
```env
VITE_API_URL=http://localhost:5000
VITE_PHP_URL=http://localhost:8080
VITE_WS_URL=ws://localhost:5000
```

## Development

Run the development server:
```bash
npm run dev
```

The application will be available at http://localhost:3000

## Build

Build for production:
```bash
npm run build
```

Preview production build:
```bash
npm run preview
```

## Features

- **Authentication**: JWT-based login/logout
- **Real-time Collaboration**: Multiple users can edit documents simultaneously
- **Rich Text Editor**: Quill-based WYSIWYG editor
- **Content Management**: Create, edit, publish, and delete content
- **Version History**: Track all changes with automatic versioning
- **User Presence**: See who's actively editing documents

## Project Structure

```
src/
├── components/      # React components
│   └── Layout.tsx   # Main layout with navigation
├── pages/           # Page components
│   ├── Login.tsx    # Authentication page
│   ├── Dashboard.tsx # Dashboard with stats
│   ├── ContentList.tsx # Content listing
│   └── Editor.tsx   # Collaborative editor
├── store/           # Zustand state management
│   ├── authStore.ts # Authentication state
│   └── collaborationStore.ts # Real-time collaboration
├── App.tsx          # Main app component
└── main.tsx         # Entry point
```

## Key Technologies

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool
- **TailwindCSS** - Styling
- **React Query** - Data fetching
- **Zustand** - State management
- **SignalR** - Real-time communication
- **React Quill** - Rich text editor

## Troubleshooting

### Port already in use
Change the port in `vite.config.ts`:
```typescript
server: {
  port: 3001, // Change to your preferred port
}
```

### Connection errors
Ensure backend services are running and environment variables are set correctly.
