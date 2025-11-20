# SSH Connection Guide

## Current Issue
You're connected to an EC2 instance, but:
- Wrong username (ec2-user instead of ubuntu)
- Missing SSH key file
- Git and project not set up

---

## Fix 1: Locate Your SSH Key

On your **local machine** (Mac), find where you saved the key:

```bash
# Check Downloads folder
ls -la ~/Downloads/cms-collaboration-key.pem

# Check SSH folder
ls -la ~/.ssh/cms-collaboration-key.pem

# Search for it
find ~ -name "cms-collaboration-key.pem" 2>/dev/null
```

---

## Fix 2: Move Key to Correct Location

Once you find it, move it:

```bash
# Move to .ssh directory
mv ~/Downloads/cms-collaboration-key.pem ~/.ssh/

# Set correct permissions
chmod 400 ~/.ssh/cms-collaboration-key.pem
```

---

## Fix 3: Connect with Correct Command

**From your local Mac terminal:**

```bash
# First, exit from the current EC2 connection
exit

# Now connect with the correct user and key
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@18.215.152.2
```

**Note**: Use `ubuntu` NOT `ec2-user`

---

## If Key File Doesn't Exist

If you can't find the `.pem` file, you need to create a new key pair:

### Option A: Use AWS Systems Manager (No Key Needed)

```bash
# Install AWS CLI if not installed
brew install awscli

# Configure AWS credentials
aws configure

# Get instance ID
aws ec2 describe-instances \
  --filters "Name=ip-address,Values=18.215.152.2" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text

# Connect via Systems Manager (no key needed!)
aws ssm start-session --target i-YOUR-INSTANCE-ID
```

### Option B: Create New Key Pair in AWS Console

1. Go to AWS Console → EC2 → Key Pairs
2. Create new key pair (download the .pem file)
3. Stop your instance
4. Detach current key pair
5. Attach new key pair
6. Start instance
7. Connect with new key

---

## After Successful Connection

Once you're logged in as `ubuntu@18.215.152.2`:

```bash
# Check current location
pwd
# Should show: /home/ubuntu

# Install Git if needed
sudo yum install -y git || sudo apt-get install -y git

# Clone repository
git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git

# Navigate to project
cd CMS_with_Collaberation-

# Run setup
chmod +x complete-setup.sh
./complete-setup.sh
```

---

## Alternative: Use Existing EC2 Instance (ec2-user)

If you want to use the current instance with `ec2-user`:

```bash
# You're already connected as ec2-user, so run:

# Install Git
sudo yum install -y git

# Clone repository
cd ~
git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
cd CMS_with_Collaberation-

# Run setup
chmod +x complete-setup.sh
./complete-setup.sh
```

This will work with `ec2-user` instead of `ubuntu`.

---

## Quick Check: Which Instance Type?

```bash
# Check OS
cat /etc/os-release

# Amazon Linux → use ec2-user
# Ubuntu → use ubuntu user
```

---

## Summary

**On your Mac (local terminal):**
```bash
# Find the key
ls -la ~/.ssh/cms-collaboration-key.pem

# Connect with correct user
ssh -i ~/.ssh/cms-collaboration-key.pem ubuntu@18.215.152.2

# OR if using Amazon Linux with ec2-user
ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@18.215.152.2
```

**On the EC2 instance:**
```bash
# Install Git (if not installed)
sudo yum install -y git        # Amazon Linux
# OR
sudo apt-get install -y git    # Ubuntu

# Clone and setup
git clone https://github.com/bholsinger09/CMS_with_Collaberation-.git
cd CMS_with_Collaberation-
chmod +x complete-setup.sh
./complete-setup.sh
```
