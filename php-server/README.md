# PHP Server Setup Guide

## Prerequisites

- PHP 8.1+
- Composer
- MySQL 8.0+

## Installation

1. Install dependencies:
```bash
composer install
```

2. Create environment file:
```bash
cp .env.example .env
```

3. Update `.env` with your database configuration:
```env
DB_HOST=localhost
DB_DATABASE=cms_collaboration
DB_USERNAME=cmsuser
DB_PASSWORD=cmspassword
```

## Development

Run the built-in PHP server:
```bash
composer start
```

Or manually:
```bash
php -S localhost:8080 -t public
```

The API will be available at http://localhost:8080

## Features

- **Content Publishing**: Serve published content to public
- **Media Management**: Upload and manage media files
- **Tag Management**: Organize content with tags
- **Export Functionality**: Export content in multiple formats
- **RESTful API**: Clean, RESTful endpoints

## Project Structure

```
php-server/
├── public/             # Web root
│   ├── index.php       # Entry point
│   └── uploads/        # Media uploads directory
├── src/
│   ├── Controllers/    # Request handlers
│   │   ├── ContentController.php
│   │   ├── MediaController.php
│   │   └── TagController.php
│   └── Middleware/     # HTTP middleware
│       └── CorsMiddleware.php
└── composer.json       # Dependencies
```

## API Endpoints

### Content
- `GET /api/content/published` - Get all published content
- `GET /api/content/{id}/html` - Get content as HTML page
- `POST /api/content/{id}/export` - Export content (JSON, HTML, Markdown)
- `GET /api/content/tags/{tag}` - Get content by tag

### Media
- `POST /api/media/upload` - Upload media file
- `GET /api/media` - List all media
- `GET /api/media/{id}` - Get specific media
- `DELETE /api/media/{id}` - Delete media

### Tags
- `GET /api/tags` - Get all tags with content count
- `POST /api/tags` - Create new tag

## Usage Examples

### Upload Media
```bash
curl -X POST http://localhost:8080/api/media/upload \
  -F "file=@image.jpg"
```

### Export Content
```bash
curl -X POST http://localhost:8080/api/content/{id}/export \
  -H "Content-Type: application/json" \
  -d '{"format": "html"}' \
  -o output.html
```

### Get Published Content
```bash
curl http://localhost:8080/api/content/published
```

## Technologies

- **Slim Framework**: Lightweight PHP framework
- **PHP-DI**: Dependency injection
- **PDO**: Database abstraction
- **PSR-7/PSR-15**: HTTP standards

## Production Deployment

### Apache Configuration

Create `.htaccess` in the `public` directory:
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ index.php [QSA,L]
```

### Nginx Configuration

```nginx
server {
    listen 80;
    server_name cms.example.com;
    root /var/www/cms/php-server/public;
    
    index index.php;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

## Security Notes

- Upload directory should have proper permissions
- Validate file types and sizes
- Use prepared statements (already implemented)
- Implement rate limiting in production
- Add authentication middleware for protected endpoints

## Troubleshooting

### Upload errors
- Check upload directory permissions: `chmod 755 public/uploads`
- Verify PHP upload settings in `php.ini`:
  ```ini
  upload_max_filesize = 10M
  post_max_size = 10M
  ```

### Database connection errors
- Verify credentials in `.env`
- Ensure MySQL is running
- Check firewall settings
