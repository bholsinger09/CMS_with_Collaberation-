# HTTPS Setup Guide

This guide explains how to enable HTTPS for your CMS using Let's Encrypt SSL certificates.

## Prerequisites

1. Domain pointing to your EC2 instance (✓ cmscallabration.duckdns.org)
2. AWS Security Group allowing ports 80 and 443
3. SSH access to EC2 instance

## Quick Setup

### Step 1: Update AWS Security Group

Add these inbound rules to your EC2 security group:

```
Port 80  (HTTP)  - Source: 0.0.0.0/0  - For Let's Encrypt challenges
Port 443 (HTTPS) - Source: 0.0.0.0/0  - For secure access
```

### Step 2: Deploy Changes

```bash
# On your local machine, commit and push changes
git add -A
git commit -m "Add HTTPS support with nginx and Let's Encrypt"
git push

# SSH to EC2
ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@3.88.158.94

# Run the deployment script
cd /home/ec2-user/CMS_Callaberation
bash deploy-https.sh
```

The script will:
- Pull latest code
- Install Certbot
- Obtain SSL certificate from Let's Encrypt
- Configure nginx as reverse proxy
- Start all services with HTTPS

### Step 3: Access Your Site

Visit: **https://cmscallabration.duckdns.org**

## What Changes?

### Architecture
- **nginx** acts as reverse proxy handling SSL/TLS
- **Frontend** accessible only through nginx
- **Backend API** routed through nginx at `/api`
- **WebSocket** connections upgraded automatically

### URLs
- Frontend: `https://cmscallabration.duckdns.org`
- Backend API: `https://cmscallabration.duckdns.org/api`
- WebSocket: `wss://cmscallabration.duckdns.org/hubs`

### Security Features
- TLS 1.2 and 1.3 only
- HSTS header (forces HTTPS)
- Rate limiting (10 req/s for API, 5 req/s for uploads)
- Security headers (XSS, clickjacking protection)

## Certificate Renewal

Certificates auto-renew via Certbot. Manual renewal:

```bash
sudo certbot renew
docker-compose restart nginx
```

## Troubleshooting

### Certificate error
```bash
# Check certificate
sudo certbot certificates

# Renew manually
sudo certbot renew --force-renewal
```

### nginx not starting
```bash
# Check nginx logs
docker logs cms_nginx

# Verify certificate permissions
sudo ls -la /etc/letsencrypt/live/cmscallabration.duckdns.org/
```

### Port 80/443 blocked
Ensure AWS Security Group allows inbound traffic on ports 80 and 443 from 0.0.0.0/0

## Rollback

To revert to HTTP:

```bash
cd /home/ec2-user/CMS_Callaberation
docker-compose down
git checkout HEAD~1 docker-compose.yml
docker-compose up -d
```

## Files Modified

- `docker-compose.yml` - Added nginx service, updated environment URLs
- `nginx/nginx.conf` - Nginx configuration with SSL and reverse proxy
- `deploy-https.sh` - Automated deployment script
- `setup-ssl.sh` - Manual SSL setup script
