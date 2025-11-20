# AWS Deployment Update Instructions

## 📝 Manual Steps to Deploy on AWS

Since automated SSH isn't working, please follow these steps to update your AWS server:

### Step 1: Connect to AWS Instance

Open a terminal and run:

```bash
ssh -i ~/Downloads/cms-collaboration-key.pem ubuntu@18.215.152.2
```

If you get a permissions error on the key file, run this first:
```bash
chmod 400 ~/Downloads/cms-collaboration-key.pem
```

### Step 2: Navigate to Project Directory

```bash
cd ~/CMS_with_Collaberation-
```

### Step 3: Pull Latest Changes

```bash
git pull origin main
```

You should see it pull the following updates:
- Fixed authentication with JWT Bearer tokens
- New registration page
- Updated database password hashes
- Fixed port configurations
- New axios interceptor for auth
- Documentation files (CREDENTIALS.md, DEPLOYMENT_STATUS.md)

### Step 4: Rebuild and Restart Containers

```bash
# Stop all containers
docker-compose down

# Rebuild and start with new changes
docker-compose up -d --build
```

This will:
- Rebuild the frontend with new auth configuration
- Rebuild PHP server with fixed DocumentRoot
- Use updated docker-compose.yml with corrected ports

### Step 5: Update Database Passwords (Important!)

The password hashes in the database need to be updated:

```bash
# Create SQL file to update passwords
cat > update_passwords.sql << 'EOF'
USE cms_collaboration;
UPDATE Users SET PasswordHash='JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=' WHERE Username='admin';
UPDATE Users SET PasswordHash='715aH7lQVeDlbMz5ikHnhKEywU5/bhuiRDAvDnKym68=' WHERE Username='editor';
SELECT Username, Email, 'Updated' as Status FROM Users WHERE Username IN ('admin', 'editor');
EOF

# Execute the SQL
docker exec -i cms_mysql mysql -ucmsuser -pcmspassword < update_passwords.sql

# Clean up
rm update_passwords.sql
```

### Step 6: Verify Deployment

Check that all containers are running:

```bash
docker ps --filter "name=cms"
```

You should see 4 containers running:
- cms_react_frontend
- cms_dotnet_backend
- cms_php_server
- cms_mysql

### Step 7: Test the Application

Access your application at:
- **Frontend**: http://cmscallabration.duckdns.org:3000
- **Backend API**: http://cmscallabration.duckdns.org:5002

**Test Credentials:**
- Email: `admin@cms.local`
- Password: `admin123`

OR

- Email: `editor@cms.local`
- Password: `editor123`

---

## 🔧 Important Notes

### Port Changes
The backend is now on port **5002** instead of 5000 (to avoid macOS conflicts). 

If you want the AWS server to use standard ports, you'll need to:

1. Update `docker-compose.yml` on AWS to use port 5000:
   ```yaml
   backend:
     ports:
       - "5000:8080"  # Instead of 5002:8080
   ```

2. Update frontend environment variables:
   ```yaml
   environment:
     - VITE_API_URL=http://cmscallabration.duckdns.org:5000
     - VITE_WS_URL=ws://cmscallabration.duckdns.org:5000
   ```

3. Rebuild: `docker-compose up -d --build`

### Troubleshooting

If you encounter issues:

**View Logs:**
```bash
# All services
docker-compose logs -f

# Specific service
docker logs cms_react_frontend -f
docker logs cms_dotnet_backend -f
```

**Restart Services:**
```bash
docker-compose restart frontend
docker-compose restart backend
```

**Complete Reset:**
```bash
docker-compose down -v  # -v removes volumes
docker-compose up -d --build
```

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] All 4 containers are running
- [ ] Frontend loads at port 3000
- [ ] Can access login page
- [ ] Can create new account
- [ ] Can login with test credentials
- [ ] Dashboard loads without 401 errors
- [ ] Can see user statistics

---

## 📚 Additional Documentation

See these files in the repo:
- `CREDENTIALS.md` - Test user credentials
- `DEPLOYMENT_STATUS.md` - Full deployment status
- `QUICKSTART.md` - Quick start guide

