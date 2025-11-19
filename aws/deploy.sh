#!/bin/bash

# Quick AWS Deployment Script for CMS Collaboration Platform
# This script automates the deployment process

set -e

echo "🚀 CMS Collaboration Platform - AWS Deployment"
echo "================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install it first.${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install it first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Prerequisites check passed"
echo ""

# Get AWS region
read -p "Enter AWS region (default: us-east-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

# Check if key pair exists
read -p "Enter your EC2 key pair name (e.g., cms-collaboration-key): " KEY_PAIR_NAME

if ! aws ec2 describe-key-pairs --key-names "$KEY_PAIR_NAME" --region "$AWS_REGION" &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} Key pair not found. Please create it in AWS Console first."
    echo "Visit: https://console.aws.amazon.com/ec2/v2/home?region=$AWS_REGION#KeyPairs"
    exit 1
fi

echo -e "${GREEN}✓${NC} Key pair found: $KEY_PAIR_NAME"
echo ""

# Database credentials
echo "Database Configuration:"
read -p "Enter database master username (default: admin): " DB_USERNAME
DB_USERNAME=${DB_USERNAME:-admin}

read -sp "Enter database password (min 8 characters): " DB_PASSWORD
echo ""

if [ ${#DB_PASSWORD} -lt 8 ]; then
    echo -e "${RED}❌ Password must be at least 8 characters${NC}"
    exit 1
fi

# Stack name
STACK_NAME="cms-collaboration-stack"

echo ""
echo "Deployment Summary:"
echo "-------------------"
echo "Stack Name: $STACK_NAME"
echo "Region: $AWS_REGION"
echo "Key Pair: $KEY_PAIR_NAME"
echo "DB Username: $DB_USERNAME"
echo ""

read -p "Proceed with deployment? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "🚀 Starting deployment..."

# Deploy CloudFormation stack
echo "Deploying CloudFormation stack..."

aws cloudformation create-stack \
  --stack-name "$STACK_NAME" \
  --template-body file://aws/cloudformation.yml \
  --parameters \
    ParameterKey=KeyPairName,ParameterValue="$KEY_PAIR_NAME" \
    ParameterKey=DBUsername,ParameterValue="$DB_USERNAME" \
    ParameterKey=DBPassword,ParameterValue="$DB_PASSWORD" \
  --capabilities CAPABILITY_IAM \
  --region "$AWS_REGION"

echo "Stack creation initiated. Waiting for completion..."
echo "This may take 10-15 minutes..."

# Wait for stack creation
aws cloudformation wait stack-create-complete \
  --stack-name "$STACK_NAME" \
  --region "$AWS_REGION"

echo -e "${GREEN}✓${NC} Stack created successfully!"
echo ""

# Get outputs
echo "Retrieving deployment information..."

OUTPUTS=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$AWS_REGION" \
  --query 'Stacks[0].Outputs' \
  --output json)

PUBLIC_IP=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="WebServerPublicIP") | .OutputValue')
FRONTEND_URL=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="FrontendURL") | .OutputValue')
BACKEND_URL=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="BackendURL") | .OutputValue')
SWAGGER_URL=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="SwaggerURL") | .OutputValue')
SSH_COMMAND=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="SSHCommand") | .OutputValue')

echo ""
echo "============================================"
echo "🎉 Deployment Complete!"
echo "============================================"
echo ""
echo "Your CMS Collaboration Platform is now running!"
echo ""
echo "📍 Access URLs:"
echo "   Frontend:  $FRONTEND_URL"
echo "   Backend:   $BACKEND_URL"
echo "   Swagger:   $SWAGGER_URL"
echo ""
echo "🔑 Default Login:"
echo "   Email:    admin@cms.local"
echo "   Password: admin123"
echo ""
echo "⚠️  IMPORTANT: Change the default password immediately!"
echo ""
echo "🔐 SSH Access:"
echo "   $SSH_COMMAND"
echo ""
echo "📊 View Stack Details:"
echo "   aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION"
echo ""
echo "🗑️  To delete everything (including data):"
echo "   aws cloudformation delete-stack --stack-name $STACK_NAME --region $AWS_REGION"
echo ""

# Save deployment info
cat > deployment-info.txt << EOF
CMS Collaboration Platform - Deployment Information
Generated: $(date)

Stack Name: $STACK_NAME
AWS Region: $AWS_REGION
Public IP: $PUBLIC_IP

Access URLs:
- Frontend: $FRONTEND_URL
- Backend API: $BACKEND_URL
- Swagger Docs: $SWAGGER_URL

SSH Command:
$SSH_COMMAND

Default Credentials:
- Email: admin@cms.local
- Password: admin123

Database:
- Username: $DB_USERNAME
- Password: [REDACTED - check CloudFormation parameters]

Next Steps:
1. Access the frontend and log in
2. Change default password
3. Configure domain name (optional)
4. Setup SSL certificate (recommended)
5. Configure backups
EOF

echo "📄 Deployment information saved to: deployment-info.txt"
echo ""
echo "Need help? Check aws/DEPLOYMENT.md for detailed documentation"
