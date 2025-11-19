# AWS Deployment Guide

Complete guide to deploying the CMS Collaboration Platform on AWS.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS Cloud                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                Application Load Balancer              │  │
│  │              (Port 80/443 - HTTPS)                    │  │
│  └─────────────┬────────────────────────────────────────┘  │
│                │                                             │
│  ┌─────────────┴─────────────────────────────────────┐     │
│  │              Target Groups                         │     │
│  │  - Frontend (3000) - Backend (5000) - PHP (8080)  │     │
│  └─────────────┬─────────────────────────────────────┘     │
│                │                                             │
│  ┌─────────────┴─────────────────────────────────────┐     │
│  │        EC2 Instances (Auto Scaling Group)         │     │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │     │
│  │  │Frontend  │  │ Backend  │  │   PHP    │        │     │
│  │  │Container │  │Container │  │Container │        │     │
│  │  └──────────┘  └──────────┘  └──────────┘        │     │
│  └───────────────────────────────────────────────────┘     │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Amazon RDS (MySQL)                        │  │
│  │         - Multi-AZ Deployment                        │  │
│  │         - Automated Backups                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Amazon S3                                  │  │
│  │         - Media Storage                               │  │
│  │         - Static Assets                               │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │       Amazon CloudFront (CDN)                         │  │
│  │         - Global Content Delivery                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Docker** installed locally
4. **SSH Key Pair** (shown in your screenshot)
5. **Domain name** (optional, recommended)

## 🚀 Deployment Options

### Option 1: EC2 with Docker (Recommended for Getting Started)
### Option 2: ECS with Fargate (Serverless Containers)
### Option 3: EKS (Kubernetes - Advanced)

---

## 🎯 Option 1: EC2 Deployment (Step-by-Step)

### Step 1: Create Key Pair

You're already on this step! Complete the form:

1. **Key pair name**: `cms-collaboration-key`
2. **Key pair type**: RSA
3. **Private key file format**: .pem (for OpenSSH)
4. Click **Create key pair**
5. **Save the downloaded .pem file** securely (you'll need it to SSH)

```bash
# Move to secure location
mv ~/Downloads/cms-collaboration-key.pem ~/.ssh/
chmod 400 ~/.ssh/cms-collaboration-key.pem
```

### Step 2: Launch EC2 Instance

```bash
# Using AWS CLI
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.medium \
  --key-name cms-collaboration-key \
  --security-group-ids sg-xxxxx \
  --subnet-id subnet-xxxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=CMS-Collaboration}]' \
  --user-data file://aws/user-data.sh
```

**Or via AWS Console:**

1. Go to **EC2 Dashboard**
2. Click **Launch Instance**
3. **Name**: CMS-Collaboration
4. **AMI**: Ubuntu Server 22.04 LTS
5. **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
6. **Key pair**: cms-collaboration-key (select the one you just created)
7. **Network Settings**:
   - Create security group or select existing
   - Allow: SSH (22), HTTP (80), HTTPS (443), Custom TCP (3000, 5000, 8080)
8. **Storage**: 30 GB gp3
9. Click **Launch Instance**

### Step 3: Configure Security Group

Create or update security group rules:

| Type | Protocol | Port Range | Source |
|------|----------|------------|--------|
| SSH | TCP | 22 | Your IP |
| HTTP | TCP | 80 | 0.0.0.0/0 |
| HTTPS | TCP | 443 | 0.0.0.0/0 |
| Custom TCP | TCP | 3000 | 0.0.0.0/0 |
| Custom TCP | TCP | 5000 | 0.0.0.0/0 |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 |
| MySQL | TCP | 3306 | Security Group ID |

```bash
# Using AWS CLI
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp=YOUR_IP/32}]'
```

### Step 4: Connect to EC2 Instance

```bash
# Get your instance public IP
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=CMS-Collaboration" \
  --query "Reservations[*].Instances[*].[PublicIpAddress]" \
  --output text

# SSH into instance
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@YOUR_INSTANCE_IP
```

### Step 5: Setup EC2 Instance

Once connected, run these commands:

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
docker --version
docker-compose --version

# Install Git
sudo apt-get install -y git

# Clone your repository
git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
cd CMS_with_Collaberation-
```

### Step 6: Create RDS MySQL Database

**Via AWS Console:**

1. Go to **RDS Dashboard**
2. Click **Create database**
3. **Engine**: MySQL 8.0
4. **Templates**: Free tier (or Production for production use)
5. **DB instance identifier**: cms-collaboration-db
6. **Master username**: admin
7. **Master password**: (create secure password)
8. **DB instance class**: db.t3.micro (free tier) or db.t3.small
9. **Storage**: 20 GB
10. **VPC**: Same as EC2
11. **Public access**: No
12. **VPC security group**: Create new or use existing
13. Click **Create database**

**Save these details:**
- Endpoint: `cms-collaboration-db.xxxxx.us-east-1.rds.amazonaws.com`
- Port: 3306
- Username: admin
- Password: (your password)

### Step 7: Configure Application

On your EC2 instance, create environment files:

```bash
cd ~/CMS_with_Collaberation-

# Frontend environment
cat > frontend/.env << EOF
VITE_API_URL=http://YOUR_EC2_PUBLIC_IP:5000
VITE_PHP_URL=http://YOUR_EC2_PUBLIC_IP:8080
VITE_WS_URL=ws://YOUR_EC2_PUBLIC_IP:5000
EOF

# Backend configuration
cat > backend/appsettings.Production.json << EOF
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_RDS_ENDPOINT;Database=cms_collaboration;User=admin;Password=YOUR_RDS_PASSWORD;"
  },
  "JwtSettings": {
    "SecretKey": "$(openssl rand -base64 32)",
    "Issuer": "CMSCollaboration",
    "Audience": "CMSCollaborationUsers",
    "ExpirationMinutes": 1440
  }
}
EOF

# PHP environment
cat > php-server/.env << EOF
DB_HOST=YOUR_RDS_ENDPOINT
DB_DATABASE=cms_collaboration
DB_USERNAME=admin
DB_PASSWORD=YOUR_RDS_PASSWORD
EOF

# Docker Compose override for production
cat > docker-compose.override.yml << EOF
version: '3.8'

services:
  frontend:
    environment:
      - NODE_ENV=production
  
  backend:
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
  
  php-server:
    environment:
      - APP_ENV=production
EOF
```

### Step 8: Initialize Database

```bash
# Connect to RDS and initialize
mysql -h YOUR_RDS_ENDPOINT -u admin -p < database/init.sql
```

### Step 9: Start Application

```bash
# Start all services with Docker Compose
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Step 10: Access Your Application

Your application is now running!

- **Frontend**: http://YOUR_EC2_PUBLIC_IP:3000
- **Backend API**: http://YOUR_EC2_PUBLIC_IP:5000
- **Swagger**: http://YOUR_EC2_PUBLIC_IP:5000/swagger
- **PHP API**: http://YOUR_EC2_PUBLIC_IP:8080

---

## 🔒 Option 2: Production Setup with HTTPS

### Install Nginx as Reverse Proxy

```bash
sudo apt-get install -y nginx certbot python3-certbot-nginx

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/cms-collaboration
```

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /php-api {
        proxy_pass http://localhost:8080;
        rewrite ^/php-api(.*)$ $1 break;
    }

    location /collaborationHub {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/cms-collaboration /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate (if you have a domain)
sudo certbot --nginx -d your-domain.com
```

---

## ☁️ Option 3: ECS Fargate Deployment

For serverless container deployment, use the provided CloudFormation template:

```bash
# Build and push Docker images to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

# Tag and push images
docker-compose build
docker tag cms-collaboration-frontend:latest YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/cms-frontend:latest
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/cms-frontend:latest

# Deploy CloudFormation stack
aws cloudformation create-stack \
  --stack-name cms-collaboration \
  --template-body file://aws/cloudformation.yml \
  --parameters file://aws/parameters.json \
  --capabilities CAPABILITY_IAM
```

---

## 📊 Monitoring & Maintenance

### Setup CloudWatch Logs

```bash
# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb

# Configure logging
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file://aws/cloudwatch-config.json
```

### Automated Backups

```bash
# Database backup script
cat > ~/backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -h YOUR_RDS_ENDPOINT -u admin -p'PASSWORD' cms_collaboration > backup_$DATE.sql
aws s3 cp backup_$DATE.sql s3://your-backup-bucket/
rm backup_$DATE.sql
EOF

chmod +x ~/backup.sh

# Add to crontab (daily at 2 AM)
crontab -e
# Add: 0 2 * * * /home/ubuntu/backup.sh
```

---

## 💰 Cost Estimation

**Monthly AWS Costs (approximate):**

### Minimal Setup:
- EC2 t3.medium: $30/month
- RDS db.t3.micro: $15/month
- Data transfer: $5/month
- **Total: ~$50/month**

### Production Setup:
- EC2 t3.large (2x): $150/month
- RDS db.t3.small (Multi-AZ): $60/month
- Application Load Balancer: $20/month
- S3 + CloudFront: $10/month
- **Total: ~$240/month**

---

## 🔧 Troubleshooting

### Can't connect to EC2:
```bash
# Check instance is running
aws ec2 describe-instance-status --instance-ids i-xxxxx

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-xxxxx
```

### Database connection issues:
```bash
# Test from EC2
mysql -h YOUR_RDS_ENDPOINT -u admin -p

# Check security group allows connection from EC2
```

### Docker containers not starting:
```bash
# Check logs
docker-compose logs

# Restart services
docker-compose down && docker-compose up -d
```

---

## 📚 Additional Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## 🎓 Next Steps

1. ✅ Complete key pair creation (as shown in your screenshot)
2. Launch EC2 instance following Step 2
3. Create RDS database (Step 6)
4. Deploy application (Steps 7-9)
5. Configure domain and SSL (Optional)
6. Setup monitoring and backups
7. Configure auto-scaling (for production)

Need help with any specific step? Let me know!
