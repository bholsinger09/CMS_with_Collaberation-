# Frontend Troubleshooting Guide

## Issue: Blank Frontend Page

### Common Causes:
1. ❌ Build not running properly
2. ❌ Wrong environment variables
3. ❌ CORS issues
4. ❌ Network connectivity problems
5. ❌ JavaScript errors

---

## Quick Fix (Run on AWS Instance)

```bash
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@18.215.152.2
cd ~/CMS_with_Collaberation-

# Run the automated fix
chmod +x fix-frontend.sh
./fix-frontend.sh
```

---

## Manual Fix Steps

### Step 1: Check Container Status
```bash
docker-compose ps
```

Expected output: All services should show "Up"

### Step 2: View Frontend Logs
```bash
docker-compose logs frontend
```

Look for errors like:
- `VITE v5.x.x ready in XXX ms`
- `Network: use --host to expose`
- Any error messages

### Step 3: Rebuild Frontend
```bash
docker-compose down
docker-compose up -d --build frontend
```

### Step 4: Check if Frontend is Responding
```bash
# From inside the instance
curl http://localhost:3000

# Should return HTML content
```

### Step 5: Check Browser Console
Open http://cmscallabration.duckdns.org:3000 in your browser and press F12:
- Look for errors in Console tab
- Check Network tab for failed requests
- Common errors:
  - CORS issues
  - Failed API calls
  - WebSocket connection failures

---

## Specific Solutions

### Solution 1: Environment Variables Missing

```bash
cd ~/CMS_with_Collaberation-

# Create proper .env file
cat > frontend/.env << 'EOF'
VITE_API_URL=http://cmscallabration.duckdns.org:5000
VITE_PHP_URL=http://cmscallabration.duckdns.org:8080
VITE_WS_URL=ws://cmscallabration.duckdns.org:5000
EOF

# Rebuild
docker-compose up -d --build frontend
```

### Solution 2: Port Already in Use

```bash
# Check what's using port 3000
sudo lsof -i :3000

# Kill the process if needed
sudo kill -9 <PID>

# Restart
docker-compose restart frontend
```

### Solution 3: Node Modules Issues

```bash
# Clear node_modules and rebuild
docker-compose down
docker volume rm cms_callaberation_frontend_node_modules 2>/dev/null || true
docker-compose up -d --build frontend
```

### Solution 4: CORS Issues (Backend)

Update backend CORS settings:

```bash
# Check backend logs
docker-compose logs backend | grep -i cors

# Backend should allow requests from your domain
```

### Solution 5: Build Production Version

If dev mode has issues, build for production:

```bash
# On AWS instance
cd ~/CMS_with_Collaberation-/frontend

# Install dependencies
docker-compose exec frontend npm install

# Build production
docker-compose exec frontend npm run build

# Serve with nginx (see below)
```

---

## Using Nginx to Serve Frontend

If Docker dev server has issues, use Nginx:

```bash
# Install nginx
sudo apt-get install -y nginx

# Build frontend
cd ~/CMS_with_Collaberation-/frontend
docker-compose exec frontend npm run build

# Copy build to nginx
sudo cp -r dist/* /var/www/html/

# Configure nginx
sudo nano /etc/nginx/sites-available/default
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name cmscallabration.duckdns.org;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Restart nginx
sudo systemctl restart nginx
```

Now access: http://cmscallabration.duckdns.org

---

## Diagnostic Commands

### Check All Services
```bash
docker-compose ps
docker-compose logs --tail=50
```

### Check Frontend Specifically
```bash
docker-compose logs -f frontend
```

### Test Network Connectivity
```bash
# From host
curl http://localhost:3000
curl http://cmscallabration.duckdns.org:3000

# From browser
# Open developer tools (F12) → Network tab
```

### Check Environment Variables Inside Container
```bash
docker-compose exec frontend env | grep VITE
```

### Check Files Inside Container
```bash
docker-compose exec frontend ls -la /app
docker-compose exec frontend cat /app/.env
```

---

## Still Not Working?

### 1. Complete Reset
```bash
cd ~/CMS_with_Collaberation-
docker-compose down -v
docker system prune -af
git pull origin main
./fix-frontend.sh
```

### 2. Check AWS Security Group
- Port 3000 should be open to 0.0.0.0/0
- Port 80 should be open (if using nginx)

### 3. Check Browser
- Clear browser cache (Ctrl+Shift+Del)
- Try incognito mode
- Try different browser
- Check if JavaScript is enabled

### 4. View Live Logs
```bash
# Terminal 1: Frontend logs
docker-compose logs -f frontend

# Terminal 2: Backend logs
docker-compose logs -f backend

# Terminal 3: Test requests
curl -v http://localhost:3000
```

---

## Success Checklist

- [ ] Docker containers are running (`docker-compose ps`)
- [ ] Frontend logs show "ready in XXXms"
- [ ] curl http://localhost:3000 returns HTML
- [ ] Browser shows content (not blank)
- [ ] Browser console has no errors
- [ ] Network tab shows successful requests
- [ ] Can login with admin@cms.local / admin123

---

## Get Help

If still having issues, run diagnostic:
```bash
chmod +x troubleshoot-frontend.sh
./troubleshoot-frontend.sh > diagnostic.log

# Share the diagnostic.log output
cat diagnostic.log
```
