# SSL/HTTPS Setup for cmscallabration.duckdns.org

## Quick SSL Setup with Let's Encrypt

### On your AWS instance, run:

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx nginx

# Stop Docker services temporarily (to free ports 80/443)
cd ~/CMS_with_Collaberation-
docker-compose down

# Get SSL certificate
sudo certbot certonly --standalone \
  -d cmscallabration.duckdns.org \
  --agree-tos \
  --email your-email@example.com

# Configure Nginx
sudo nano /etc/nginx/sites-available/cms-collaboration
```

### Nginx Configuration:

```nginx
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name cmscallabration.duckdns.org;
    return 301 https://$server_name$request_uri;
}

# HTTPS - Frontend
server {
    listen 443 ssl http2;
    server_name cmscallabration.duckdns.org;

    ssl_certificate /etc/letsencrypt/live/cmscallabration.duckdns.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/cmscallabration.duckdns.org/privkey.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # SignalR WebSocket
    location /collaborationHub {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # PHP API
    location /php-api {
        proxy_pass http://localhost:8080;
        rewrite ^/php-api(.*)$ $1 break;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Swagger
    location /swagger {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Enable and Start:

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/cms-collaboration /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Update frontend environment for HTTPS
cd ~/CMS_with_Collaberation-
cat > frontend/.env << 'EOF'
VITE_API_URL=https://cmscallabration.duckdns.org/api
VITE_PHP_URL=https://cmscallabration.duckdns.org/php-api
VITE_WS_URL=wss://cmscallabration.duckdns.org/collaborationHub
EOF

# Restart Docker services
docker-compose up -d --build
```

### Auto-renewal:

```bash
# Test renewal
sudo certbot renew --dry-run

# Certbot automatically sets up a cron job for renewal
```

---

## After SSL Setup:

### ✅ Your URLs will be:
- **Frontend**: https://cmscallabration.duckdns.org
- **Backend API**: https://cmscallabration.duckdns.org/api
- **Swagger**: https://cmscallabration.duckdns.org/swagger
- **PHP API**: https://cmscallabration.duckdns.org/php-api

### 🔒 Security Checklist:
- ✅ SSL certificate installed
- ✅ HTTP redirects to HTTPS
- ✅ Security headers configured
- ✅ WebSocket (WSS) support enabled
- ⏳ Change default admin password
- ⏳ Update CORS settings in backend
- ⏳ Configure firewall rules

---

## Without SSL (Current Setup):

If you want to use the domain without SSL for now:

### Update AWS Security Group:
Make sure ports 80, 3000, 5000, 8080 are open

### Access:
- http://cmscallabration.duckdns.org:3000 (Frontend)
- http://cmscallabration.duckdns.org:5000 (Backend)
- http://cmscallabration.duckdns.org:8080 (PHP)

The environment files have been updated to use your domain!
