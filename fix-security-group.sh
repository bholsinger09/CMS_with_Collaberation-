#!/bin/bash

# Fix AWS Security Group to allow required ports
# This script opens ports 3000, 5002, and 8080 for the CMS application

echo "🔒 Fixing AWS Security Group..."
echo ""

INSTANCE_IP="3.88.158.94"

# Get instance ID from IP
echo "1. Finding EC2 instance..."
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=ip-address,Values=$INSTANCE_IP" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text 2>/dev/null)

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
    echo "❌ Could not find instance. Make sure AWS CLI is configured."
    echo ""
    echo "To configure AWS CLI:"
    echo "  aws configure"
    echo ""
    echo "Or manually add these ports in AWS Console:"
    echo "  - Port 3000 (Frontend)"
    echo "  - Port 5002 (Backend API)"
    echo "  - Port 8080 (PHP API)"
    echo ""
    echo "Go to: EC2 → Instances → Select your instance → Security tab → Security groups → Edit inbound rules"
    exit 1
fi

echo "✅ Found instance: $INSTANCE_ID"
echo ""

# Get security group ID
echo "2. Getting security group..."
SG_ID=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
    --output text)

echo "✅ Security Group: $SG_ID"
echo ""

# Add inbound rules
echo "3. Adding inbound rules..."

# Port 3000 - Frontend
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0 2>/dev/null && echo "✅ Added port 3000 (Frontend)" || echo "⚠️  Port 3000 may already be open"

# Port 5002 - Backend API  
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 5002 \
    --cidr 0.0.0.0/0 2>/dev/null && echo "✅ Added port 5002 (Backend)" || echo "⚠️  Port 5002 may already be open"

# Port 8080 - PHP API
aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 8080 \
    --cidr 0.0.0.0/0 2>/dev/null && echo "✅ Added port 8080 (PHP)" || echo "⚠️  Port 8080 may already be open"

echo ""
echo "4. Verifying rules..."
aws ec2 describe-security-groups --group-ids "$SG_ID" \
    --query "SecurityGroups[0].IpPermissions[?ToPort==\`3000\` || ToPort==\`5002\` || ToPort==\`8080\`].[FromPort,ToPort,IpProtocol]" \
    --output table

echo ""
echo "================================================"
echo "✅ Security group configuration complete!"
echo ""
echo "Your services should now be accessible at:"
echo "  Frontend: http://$INSTANCE_IP:3000"
echo "  Backend:  http://$INSTANCE_IP:5002"
echo "  PHP API:  http://$INSTANCE_IP:8080"
