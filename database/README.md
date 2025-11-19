# Database Setup

This directory contains database migration and initialization scripts for the CMS Collaboration Platform.

## Files

- `init.sql` - Initial database schema and sample data
- `migrations/` - Database migration scripts (future)

## Setup Instructions

### Using Docker Compose

The database will be automatically initialized when you run:

```bash
docker-compose up -d
```

### Manual Setup

1. Create the database:
```bash
mysql -u root -p < init.sql
```

2. Create a user (if not using root):
```bash
mysql -u root -p
```

```sql
CREATE USER 'cmsuser'@'localhost' IDENTIFIED BY 'cmspassword';
GRANT ALL PRIVILEGES ON cms_collaboration.* TO 'cmsuser'@'localhost';
FLUSH PRIVILEGES;
```

## Database Schema

### Tables

- **Users** - User accounts and authentication
- **Contents** - Main content/documents
- **ContentVersions** - Version history for content
- **CollaborationSessions** - Active collaboration sessions
- **Tags** - Content tags
- **ContentTags** - Content-Tag relationships
- **Media** - Uploaded media files
- **Comments** - Content comments
- **ActivityLog** - User activity tracking

## Default Users

### Admin Account
- **Email**: admin@cms.local
- **Password**: admin123
- **Role**: Admin

### Editor Account
- **Email**: editor@cms.local
- **Password**: password123
- **Role**: Editor

**⚠️ IMPORTANT: Change these passwords immediately in production!**

## Backup

To backup the database:

```bash
mysqldump -u cmsuser -p cms_collaboration > backup_$(date +%Y%m%d).sql
```

To restore:

```bash
mysql -u cmsuser -p cms_collaboration < backup_20231120.sql
```

## Migrations

Future migrations will be stored in the `migrations/` directory with the naming convention:
`YYYYMMDD_HHMMSS_description.sql`
