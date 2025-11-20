# Quick Fix for Docker Compose Build Error

## Error Message
```
compose build requires buildx 0.17 or later
```

This means your Docker version is outdated.

---

## ✅ Quick Fix (Run on EC2)

You're already in the right directory, just run:

```bash
# Fix Docker version
chmod +x fix-docker.sh
./fix-docker.sh

# Then log out and back in
exit

# Reconnect
ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@18.215.152.2

# Deploy
cd ~/CMS_with_Collaberation-
chmod +x deploy-simple.sh
./deploy-simple.sh
```

---

## What the Scripts Do

### fix-docker.sh:
- Updates Docker to latest version
- Installs Docker Compose V2
- Adds your user to docker group

### deploy-simple.sh:
- Creates environment files
- Starts all services with Docker Compose
- Shows status and access URLs

---

## Alternative: Manual Steps

If scripts don't work, run manually:

```bash
# Update Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker-compose --version

# Should show v2.24.0 or later

# Now deploy
cd ~/CMS_with_Collaberation-
docker-compose down
docker-compose up -d --build
```

---

## Check Progress

```bash
# View all containers
docker-compose ps

# View specific service logs
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f mysql

# Restart a service
docker-compose restart frontend
```

---

## If Still Having Issues

Try without building (use simpler images):

```bash
# Stop everything
docker-compose down

# Start just the database first
docker-compose up -d mysql

# Wait 10 seconds
sleep 10

# Start backend
docker-compose up -d backend php-server

# Wait 10 seconds
sleep 10

# Start frontend
docker-compose up -d frontend

# Check status
docker-compose ps
```

---

## Success Check

All services should show "Up":
```bash
docker-compose ps
```

Expected output:
```
NAME                     STATUS
cms_dotnet_backend       Up
cms_mysql                Up
cms_php_server           Up
cms_react_frontend       Up
```

Then access: http://cmscallabration.duckdns.org:3000
