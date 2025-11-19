# AWS Instance Information

**Instance Public IP**: `18.215.152.2`  
**Created**: November 19, 2025  
**Key Pair**: `cms-collaboration-key`

---

## 🔐 Connect to Your Instance

```bash
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@18.215.152.2
```

---

## 🌐 Access URLs

- **Frontend**: http://18.215.152.2:3000
- **Backend API**: http://18.215.152.2:5000
- **Swagger Docs**: http://18.215.152.2:5000/swagger
- **PHP Server**: http://18.215.152.2:8080

---

## 🚀 Deploy Application to Instance

### Step 1: Connect to Instance
```bash
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@18.215.152.2
```

### Step 2: Once Connected, Run Setup
```bash
# Clone repository
git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
cd CMS_with_Collaberation-

# Run setup script
chmod +x setup.sh
./setup.sh
```

### Step 3: Start with Docker (Recommended)
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

---

## 📋 Quick Commands

### Check Service Status
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f php-server
```

### Restart Services
```bash
docker-compose restart
```

### Stop Services
```bash
docker-compose down
```

### Update Code
```bash
git pull origin main
docker-compose down
docker-compose up -d --build
```

---

## 🔍 Verify Installation

### 1. Check Docker is Running
```bash
docker ps
```

### 2. Test Frontend
```bash
curl http://18.215.152.2:3000
```

### 3. Test Backend API
```bash
curl http://18.215.152.2:5000/api/health
```

### 4. Test PHP Server
```bash
curl http://18.215.152.2:8080/api/content/published
```

---

## 🔑 Default Login Credentials

- **Email**: `admin@cms.local`
- **Password**: `admin123`

⚠️ **Change these immediately after first login!**

---

## 🛠️ Troubleshooting

### If you can't connect via SSH:
1. Check security group allows SSH (port 22) from your IP
2. Verify key permissions: `chmod 400 ~/.ssh/cms-collaboration-key.pem`
3. Confirm instance is running in AWS Console

### If services aren't accessible:
1. Check security group allows ports 3000, 5000, 8080
2. Verify services are running: `docker-compose ps`
3. Check firewall: `sudo ufw status`

### If Docker isn't installed:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
```

### Database Connection Issues:
```bash
# Check MySQL is running
docker-compose ps mysql

# Connect to MySQL
docker-compose exec mysql mysql -u root -p
# Password: root_password
```

---

## 📊 Monitoring

### System Resources
```bash
# CPU and Memory
htop

# Disk usage
df -h

# Docker stats
docker stats
```

### Application Logs
```bash
# Frontend
docker-compose logs frontend --tail=100 -f

# Backend
docker-compose logs backend --tail=100 -f

# PHP
docker-compose logs php-server --tail=100 -f
```

---

## 🔄 Update Deployment

### Push changes from local:
```bash
git add .
git commit -m "your message"
git push origin main
```

### Pull on server:
```bash
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@18.215.152.2
cd CMS_with_Collaberation-
git pull origin main
docker-compose up -d --build
```

---

## 📱 Next Steps

1. ✅ SSH into instance
2. ✅ Install Docker & dependencies
3. ✅ Clone repository
4. ✅ Start services with Docker Compose
5. ⏳ Access http://18.215.152.2:3000
6. ⏳ Login and change default password
7. ⏳ Configure domain (optional)
8. ⏳ Setup SSL certificate (recommended)
