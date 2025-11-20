# Quick Fix for "Request Timed Out" Error

## Issue
The browser shows: **"Failed to load resource: The request timed out"**

This means the frontend service isn't responding on port 3000.

---

## Quick Fix on AWS Instance

```bash
# Connect to your instance
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@18.215.152.2

# Navigate to project
cd ~/CMS_with_Collaberation-

# Pull latest fixes
git pull origin main

# Run complete setup
chmod +x complete-setup.sh
./complete-setup.sh
```

This will:
1. Install/verify Docker
2. Pull latest code
3. Create environment files
4. Rebuild all containers from scratch
5. Start services and verify they're running
6. Show logs for troubleshooting

---

## Manual Fix Steps

### 1. Check if Containers are Running
```bash
docker-compose ps
```

Expected: All services show "Up" status

### 2. Check Frontend Container Logs
```bash
docker-compose logs frontend
```

Look for:
- ✅ `VITE v5.x.x ready in XXX ms`
- ✅ `➜  Local:   http://localhost:3000/`
- ✅ `➜  Network: http://0.0.0.0:3000/`
- ❌ Any error messages

### 3. Restart Frontend Service
```bash
docker-compose restart frontend
docker-compose logs -f frontend
```

### 4. Rebuild if Needed
```bash
docker-compose down
docker-compose build --no-cache frontend
docker-compose up -d
```

### 5. Check Port Access
```bash
# From inside AWS instance
curl -I http://localhost:3000

# Should return HTTP 200
```

---

## AWS Security Group Check

**Critical**: Port 3000 must be open in your Security Group

1. Go to EC2 Dashboard → Security Groups
2. Find your instance's security group
3. Check Inbound Rules:

| Type | Protocol | Port | Source |
|------|----------|------|--------|
| Custom TCP | TCP | 3000 | 0.0.0.0/0 |
| Custom TCP | TCP | 5000 | 0.0.0.0/0 |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 |

### Add Rule via AWS CLI:
```bash
# Get your security group ID
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=CMS-Collaboration*" \
  --query 'Reservations[*].Instances[*].SecurityGroups[0].GroupId' \
  --output text

# Add port 3000 (replace sg-xxxxx with your security group ID)
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0
```

---

## Common Causes & Solutions

### Cause 1: Frontend Container Not Running
```bash
# Check status
docker-compose ps frontend

# If "Exit" or not listed:
docker-compose up -d frontend
docker-compose logs frontend
```

### Cause 2: Port Already in Use
```bash
# Check what's using port 3000
sudo lsof -i :3000

# Kill the process
sudo kill -9 <PID>

# Restart container
docker-compose restart frontend
```

### Cause 3: Firewall Blocking
```bash
# Check firewall status
sudo ufw status

# If active, allow port 3000
sudo ufw allow 3000/tcp
```

### Cause 4: Node Modules Issue
```bash
# Rebuild with fresh dependencies
docker-compose down
docker-compose build --no-cache frontend
docker-compose up -d
```

### Cause 5: Wrong Environment Variables
```bash
# Recreate .env file
cat > frontend/.env << 'EOF'
VITE_API_URL=http://cmscallabration.duckdns.org:5000
VITE_PHP_URL=http://cmscallabration.duckdns.org:8080
VITE_WS_URL=ws://cmscallabration.duckdns.org:5000
EOF

# Restart
docker-compose restart frontend
```

---

## Verify It's Working

### Test 1: From AWS Instance
```bash
curl -v http://localhost:3000
# Should return HTML with status 200
```

### Test 2: From Browser
1. Open http://cmscallabration.duckdns.org:3000
2. Press F12 (Developer Tools)
3. Check Console tab for errors
4. Check Network tab - should show successful requests

### Test 3: Container Health
```bash
# Container should be "Up"
docker-compose ps

# Should show VITE ready
docker-compose logs frontend | grep "ready"

# Should see network exposed
docker-compose logs frontend | grep "Network"
```

---

## Still Timing Out?

### Full Reset:
```bash
cd ~/CMS_with_Collaberation-

# Complete cleanup
docker-compose down -v
docker system prune -af --volumes

# Fresh start
git pull origin main
./complete-setup.sh
```

### Check DuckDNS:
```bash
# Verify DNS is pointing to your instance
nslookup cmscallabration.duckdns.org

# Should return your AWS instance IP: 18.215.152.2
```

### Test Direct IP:
```bash
# Try accessing via IP instead of domain
curl http://18.215.152.2:3000

# Or in browser:
http://18.215.152.2:3000
```

---

## Success Checklist

- [ ] Docker and Docker Compose installed
- [ ] All containers running (`docker-compose ps`)
- [ ] Frontend logs show "ready in XXXms"
- [ ] `curl http://localhost:3000` returns HTML
- [ ] Port 3000 open in AWS Security Group
- [ ] No firewall blocking port 3000
- [ ] Browser can reach http://cmscallabration.duckdns.org:3000
- [ ] No timeout errors in browser console

---

## Get Detailed Diagnostics

```bash
# Save full diagnostic to file
./troubleshoot-frontend.sh > diagnostic.log

# View the output
cat diagnostic.log
```

This will show exactly what's wrong!
