#!/bin/bash

# AWS EC2 User Data Script
# This script runs automatically when the EC2 instance launches

set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git and other utilities
apt-get install -y git nginx mysql-client

# Install AWS CLI
apt-get install -y awscli

# Clone repository
cd /home/ubuntu
git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
chown -R ubuntu:ubuntu CMS_with_Collaberation-

# Create deployment script
cat > /home/ubuntu/deploy.sh << 'DEPLOY_SCRIPT'
#!/bin/bash

cd /home/ubuntu/CMS_with_Collaberation-

# Pull latest changes
git pull origin main

# Update environment files with instance metadata
INSTANCE_IP=$(ec2-metadata --public-ipv4 | cut -d " " -f 2)

# Frontend environment
cat > frontend/.env << EOF
VITE_API_URL=http://${INSTANCE_IP}:5000
VITE_PHP_URL=http://${INSTANCE_IP}:8080
VITE_WS_URL=ws://${INSTANCE_IP}:5000
EOF

# Restart Docker containers
docker-compose down
docker-compose up -d

echo "Deployment completed at $(date)"
DEPLOY_SCRIPT

chmod +x /home/ubuntu/deploy.sh
chown ubuntu:ubuntu /home/ubuntu/deploy.sh

# Setup automatic deployment on boot
cat > /etc/systemd/system/cms-collaboration.service << 'SERVICE'
[Unit]
Description=CMS Collaboration Platform
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/CMS_with_Collaberation-
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ubuntu

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable cms-collaboration.service

# Create log directory
mkdir -p /var/log/cms-collaboration
chown -R ubuntu:ubuntu /var/log/cms-collaboration

# Setup CloudWatch logs (if IAM role has permissions)
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Initial deployment
su - ubuntu -c "/home/ubuntu/deploy.sh"

echo "EC2 instance setup completed!"
