# AWS CLI Quick Reference for CMS Collaboration Platform

## Stack Management

### Create Stack
```bash
aws cloudformation create-stack \
  --stack-name cms-collaboration-stack \
  --template-body file://aws/cloudformation.yml \
  --parameters \
    ParameterKey=KeyPairName,ParameterValue=cms-collaboration-key \
    ParameterKey=DBUsername,ParameterValue=admin \
    ParameterKey=DBPassword,ParameterValue=YOUR_PASSWORD \
  --capabilities CAPABILITY_IAM \
  --region us-east-1
```

### Check Stack Status
```bash
aws cloudformation describe-stacks \
  --stack-name cms-collaboration-stack \
  --region us-east-1
```

### Get Stack Outputs
```bash
aws cloudformation describe-stacks \
  --stack-name cms-collaboration-stack \
  --query 'Stacks[0].Outputs' \
  --output table
```

### Delete Stack
```bash
aws cloudformation delete-stack \
  --stack-name cms-collaboration-stack \
  --region us-east-1
```

## EC2 Management

### List Instances
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=CMS-Collaboration-Server" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table
```

### Connect via SSH
```bash
# Get instance IP
INSTANCE_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=CMS-Collaboration-Server" \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text)

# Connect
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@$INSTANCE_IP
```

### Start/Stop Instance
```bash
# Stop
aws ec2 stop-instances --instance-ids i-xxxxx

# Start
aws ec2 start-instances --instance-ids i-xxxxx
```

## RDS Management

### Describe Database
```bash
aws rds describe-db-instances \
  --db-instance-identifier cms-collaboration-db
```

### Get Database Endpoint
```bash
aws rds describe-db-instances \
  --db-instance-identifier cms-collaboration-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

### Create Snapshot
```bash
aws rds create-db-snapshot \
  --db-instance-identifier cms-collaboration-db \
  --db-snapshot-identifier cms-collaboration-backup-$(date +%Y%m%d)
```

## S3 Management

### List Files
```bash
aws s3 ls s3://cms-collaboration-media-YOUR_ACCOUNT_ID/
```

### Upload File
```bash
aws s3 cp file.jpg s3://cms-collaboration-media-YOUR_ACCOUNT_ID/
```

### Sync Directory
```bash
aws s3 sync ./uploads s3://cms-collaboration-media-YOUR_ACCOUNT_ID/uploads/
```

## CloudWatch Logs

### View Logs
```bash
# List log groups
aws logs describe-log-groups

# Get log streams
aws logs describe-log-streams \
  --log-group-name /aws/ec2/cms-collaboration

# View logs
aws logs tail /aws/ec2/cms-collaboration --follow
```

## Useful Queries

### Get All Resources
```bash
aws cloudformation list-stack-resources \
  --stack-name cms-collaboration-stack \
  --output table
```

### Cost Estimation
```bash
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter file://filter.json
```

### Security Group Rules
```bash
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=CMS-WebServer-SG" \
  --query 'SecurityGroups[0].IpPermissions'
```

## Troubleshooting

### Check Instance Status
```bash
aws ec2 describe-instance-status --instance-ids i-xxxxx
```

### View System Logs
```bash
aws ec2 get-console-output --instance-id i-xxxxx
```

### Test Database Connection
```bash
# From your local machine
mysql -h YOUR_RDS_ENDPOINT -u admin -p
```

## Deployment Scripts

### Quick Deploy
```bash
chmod +x aws/deploy.sh
./aws/deploy.sh
```

### Manual Steps
```bash
# 1. Create key pair
aws ec2 create-key-pair \
  --key-name cms-collaboration-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/cms-collaboration-key.pem
chmod 400 ~/.ssh/cms-collaboration-key.pem

# 2. Deploy stack
aws cloudformation create-stack \
  --stack-name cms-collaboration-stack \
  --template-body file://aws/cloudformation.yml \
  --parameters file://aws/parameters.json \
  --capabilities CAPABILITY_IAM

# 3. Wait for completion
aws cloudformation wait stack-create-complete \
  --stack-name cms-collaboration-stack

# 4. Get outputs
aws cloudformation describe-stacks \
  --stack-name cms-collaboration-stack \
  --query 'Stacks[0].Outputs'
```

## Monitoring

### CloudWatch Metrics
```bash
# CPU Utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxxxx \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average

# Database Connections
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value=cms-collaboration-db \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average
```

## Backup & Restore

### Backup
```bash
# Database
aws rds create-db-snapshot \
  --db-instance-identifier cms-collaboration-db \
  --db-snapshot-identifier backup-$(date +%Y%m%d)

# S3 files
aws s3 sync s3://cms-collaboration-media-YOUR_ACCOUNT_ID/ ./backup/
```

### Restore
```bash
# Database from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier cms-collaboration-db-restored \
  --db-snapshot-identifier backup-20241119
```

## Clean Up

### Delete Everything
```bash
# Delete CloudFormation stack (this deletes most resources)
aws cloudformation delete-stack --stack-name cms-collaboration-stack

# Manually delete S3 bucket if needed
aws s3 rb s3://cms-collaboration-media-YOUR_ACCOUNT_ID --force
```
