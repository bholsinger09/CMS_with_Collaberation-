#!/bin/bash

# DuckDNS Setup Script for CMS Collaboration Platform
# This script configures DuckDNS to point to your EC2 instance

echo "🦆 DuckDNS Setup for CMS Collaboration"
echo "======================================="
echo ""

# Configuration
DOMAIN="cmscallabration"
EC2_IP="3.88.158.94"

# Check if token is provided
if [ -z "$1" ]; then
    echo "❌ Error: DuckDNS token required"
    echo ""
    echo "Usage: ./setup-duckdns.sh YOUR_DUCKDNS_TOKEN"
    echo ""
    echo "To get your token:"
    echo "1. Go to https://www.duckdns.org/"
    echo "2. Sign in with your account"
    echo "3. Copy your token from the top of the page"
    echo ""
    exit 1
fi

TOKEN="$1"

echo "📝 Configuration:"
echo "  Domain: ${DOMAIN}.duckdns.org"
echo "  IP Address: $EC2_IP"
echo ""

# Update DuckDNS
echo "1. Updating DuckDNS record..."
RESPONSE=$(curl -sk "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=${EC2_IP}")

if [ "$RESPONSE" = "OK" ]; then
    echo "✅ DuckDNS updated successfully"
else
    echo "❌ Failed to update DuckDNS: $RESPONSE"
    exit 1
fi
echo ""

# Wait for DNS propagation
echo "2. Waiting for DNS propagation (10 seconds)..."
sleep 10

# Test DNS resolution
echo "3. Testing DNS resolution..."
RESOLVED_IP=$(nslookup ${DOMAIN}.duckdns.org 2>/dev/null | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)

if [ "$RESOLVED_IP" = "$EC2_IP" ]; then
    echo "✅ DNS resolving correctly to $RESOLVED_IP"
else
    echo "⚠️  DNS resolving to: $RESOLVED_IP (expected: $EC2_IP)"
    echo "   Note: DNS propagation may take a few minutes"
fi
echo ""

# Create update script on EC2
echo "4. Installing DuckDNS auto-update on EC2..."
ssh -i ~/.ssh/cms-collaboration-key.pem ec2-user@$EC2_IP << EOF
    # Create DuckDNS directory
    mkdir -p /home/ec2-user/duckdns
    cd /home/ec2-user/duckdns
    
    # Create update script
    cat > duck.sh << 'SCRIPT'
#!/bin/bash
echo url="https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=" | curl -k -o /home/ec2-user/duckdns/duck.log -K -
SCRIPT
    
    # Make it executable
    chmod +x duck.sh
    
    # Add to crontab (update every 5 minutes)
    (crontab -l 2>/dev/null | grep -v duck.sh; echo "*/5 * * * * /home/ec2-user/duckdns/duck.sh >/dev/null 2>&1") | crontab -
    
    # Run once now
    ./duck.sh
    
    echo "DuckDNS auto-update installed"
EOF

echo "✅ Auto-update configured on EC2"
echo ""

# Test HTTP access
echo "5. Testing HTTP access..."
HTTP_STATUS=$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 10 http://${DOMAIN}.duckdns.org:3000 2>/dev/null || echo "TIMEOUT")

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Frontend accessible via DuckDNS"
else
    echo "⚠️  Frontend status: $HTTP_STATUS"
    echo "   If DNS just updated, try again in a few minutes"
fi
echo ""

echo "======================================="
echo "✅ DuckDNS Setup Complete!"
echo ""
echo "Your services are available at:"
echo "  Frontend: http://${DOMAIN}.duckdns.org:3000"
echo "  Backend:  http://${DOMAIN}.duckdns.org:5002"
echo "  PHP API:  http://${DOMAIN}.duckdns.org:8080"
echo ""
echo "DuckDNS will auto-update every 5 minutes via cron job."
