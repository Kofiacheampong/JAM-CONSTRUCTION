#!/bin/bash
# JAM Construction - Deployment Update Script
# Updates the live website on Oracle Linux server

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration - UPDATE THESE VALUES
SERVER_IP="163.192.122.38"  # Replace with your actual server IP
SERVER_USER="opc"
SSH_KEY="~/.ssh/Jam_Construction_key"  # SSH key for Oracle Cloud
LOCAL_PROJECT_PATH="/Users/kofiarcher/Documents/JAM"

echo -e "${BLUE}🚀 JAM Construction - Deployment Update${NC}"
echo -e "${BLUE}Deploying from: $LOCAL_PROJECT_PATH${NC}"
echo -e "${BLUE}Deploying to: $SERVER_USER@$SERVER_IP${NC}"

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1 successful${NC}"
    else
        echo -e "${RED}❌ $1 failed${NC}"
        exit 1
    fi
}

# Validate configuration
if [ "$SERVER_IP" = "YOUR-SERVER-IP" ]; then
    echo -e "${RED}❌ Please update SERVER_IP in this script with your actual server IP${NC}"
    exit 1
fi

# Check if we can reach the server
echo -e "${BLUE}📡 Testing connection to server...${NC}"
ssh -i $SSH_KEY -o ConnectTimeout=5 $SERVER_USER@$SERVER_IP "echo 'Connection successful'" 2>/dev/null
check_status "Server connection"

# Create backup of current website
echo -e "${BLUE}💾 Creating backup of current website...${NC}"
BACKUP_NAME="website-backup-$(date +%Y%m%d-%H%M%S)"
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "sudo cp -r /var/www/html /home/opc/$BACKUP_NAME && sudo chown -R opc:opc /home/opc/$BACKUP_NAME"
check_status "Website backup"

# Upload new files to server
echo -e "${BLUE}📤 Uploading website files...${NC}"
rsync -avz --progress --exclude='.git' --exclude='*.sh' --exclude='*.md' -e "ssh -i $SSH_KEY" $LOCAL_PROJECT_PATH/ $SERVER_USER@$SERVER_IP:/home/opc/website-update/
check_status "File upload"

# Deploy files on server
echo -e "${BLUE}🚀 Deploying files on server...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP << 'EOF'
    # Remove old files (except backups)
    sudo find /var/www/html -name "website-backup-*" -prune -o -type f -delete
    sudo find /var/www/html -name "website-backup-*" -prune -o -type d -empty -delete
    
    # Copy new files
    sudo cp -r /home/opc/website-update/* /var/www/html/
    
    # Set proper permissions
    sudo chown -R apache:apache /var/www/html/
    sudo chmod -R 755 /var/www/html/
    
    # Set SELinux context if needed
    if command -v restorecon >/dev/null 2>&1; then
        sudo restorecon -Rv /var/www/html/
    fi
    
    # Clean up temporary upload directory
    rm -rf /home/opc/website-update
EOF
check_status "File deployment"

# Test Apache configuration
echo -e "${BLUE}🧪 Testing Apache configuration...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "sudo httpd -t"
check_status "Apache configuration test"

# Restart Apache to ensure changes take effect
echo -e "${BLUE}🔄 Restarting Apache...${NC}"
ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP "sudo systemctl restart httpd"
check_status "Apache restart"

# Verify deployment
echo -e "${BLUE}✅ Verifying deployment...${NC}"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$SERVER_IP)
if [ "$RESPONSE" = "200" ]; then
    echo -e "${GREEN}✅ Website is responding correctly${NC}"
else
    echo -e "${YELLOW}⚠️ Website returned HTTP $RESPONSE${NC}"
fi

# Get deployment summary
echo -e "${GREEN}"
echo "=========================================="
echo "🎉 DEPLOYMENT COMPLETE!"
echo "=========================================="
echo -e "${NC}"
echo -e "${BLUE}🌐 Website URL: http://$SERVER_IP${NC}"
echo -e "${BLUE}📧 Server IP: $SERVER_IP${NC}"
echo ""
echo -e "${YELLOW}📋 DEPLOYMENT SUMMARY:${NC}"
echo -e "${GREEN}✅${NC} Files uploaded and deployed"
echo -e "${GREEN}✅${NC} Permissions set correctly"  
echo -e "${GREEN}✅${NC} Apache restarted"
echo -e "${GREEN}✅${NC} Backup created: $BACKUP_NAME"
echo ""
echo -e "${YELLOW}🔧 USEFUL COMMANDS:${NC}"
echo "Check logs: ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP 'sudo tail -f /var/log/httpd/jamconst_error.log'"
echo "Rollback: ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP 'sudo cp -r /home/opc/$BACKUP_NAME/* /var/www/html/ && sudo chown -R apache:apache /var/www/html/'"
echo "SSH to server: ssh -i $SSH_KEY $SERVER_USER@$SERVER_IP"

echo -e "${GREEN}✨ Deployment update complete!${NC}"