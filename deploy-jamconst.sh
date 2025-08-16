#!/bin/bash
# JAM Construction - Oracle Cloud Deployment Script
# Run this script on your Oracle Cloud instance after initial setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting JAM Construction website deployment...${NC}"

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1 successful${NC}"
    else
        echo -e "${RED}❌ $1 failed${NC}"
        exit 1
    fi
}

# Update system
echo -e "${BLUE}📦 Updating system packages...${NC}"
sudo dnf update -y
check_status "System update"

# Install EPEL repository first (needed for certbot)
echo -e "${BLUE}📦 Installing EPEL repository...${NC}"
sudo dnf install -y epel-release
check_status "EPEL installation"

# Install required packages
echo -e "${BLUE}🔧 Installing Apache and SSL tools...${NC}"
sudo dnf install -y httpd mod_ssl mod_headers mod_deflate mod_expires certbot python3-certbot-apache firewalld
check_status "Package installation"

# Start and enable services
echo -e "${BLUE}⚡ Starting services...${NC}"
sudo systemctl start httpd
check_status "Apache start"

sudo systemctl enable httpd
check_status "Apache enable"

sudo systemctl start firewalld
check_status "Firewall start"

sudo systemctl enable firewalld
check_status "Firewall enable"

# Configure firewall
echo -e "${BLUE}🔥 Configuring firewall...${NC}"
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
check_status "Firewall configuration"

# Create website directory and set permissions
echo -e "${BLUE}📁 Setting up website directory...${NC}"
sudo mkdir -p /var/www/html/jamconst
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
check_status "Directory setup"

# Copy website files (assumes files are in current directory)
echo -e "${BLUE}📋 Copying website files...${NC}"
if [ -f "index.html" ]; then
    # Copy all files from current directory to web root
    sudo cp -r * /var/www/html/
    sudo chown -R apache:apache /var/www/html/
    sudo chmod -R 755 /var/www/html/
    echo -e "${GREEN}✅ Website files copied successfully${NC}"
elif [ -d "/home/opc/website" ]; then
    # Alternative: check for website directory
    sudo cp -r /home/opc/website/* /var/www/html/
    sudo chown -R apache:apache /var/www/html/
    sudo chmod -R 755 /var/www/html/
    echo -e "${GREEN}✅ Website files copied from /home/opc/website/${NC}"
else
    echo -e "${YELLOW}⚠️  No website files found in current directory${NC}"
    echo -e "${YELLOW}Creating a temporary index.html...${NC}"
    
    # Create a temporary welcome page
    sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JAM Construction - Coming Soon</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Arial', sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container { 
            background: white; 
            padding: 3rem; 
            border-radius: 15px; 
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 500px;
            margin: 2rem;
        }
        h1 { 
            color: #333; 
            margin-bottom: 1rem;
            font-size: 2.5rem;
        }
        .status { 
            color: #28a745; 
            font-weight: bold; 
            font-size: 1.2rem;
            margin-bottom: 1rem;
        }
        p { 
            color: #666; 
            line-height: 1.6; 
            margin-bottom: 1rem;
        }
        .instructions {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 8px;
            margin-top: 2rem;
            text-align: left;
        }
        code {
            background: #e9ecef;
            padding: 0.2rem 0.4rem;
            border-radius: 3px;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏗️ JAM Construction</h1>
        <p class="status">✅ Server is running successfully!</p>
        <p>Your Apache server is configured and ready.</p>
        <p><strong>Server Time:</strong> $(date)</p>
        
        <div class="instructions">
            <h3>📋 Next Steps:</h3>
            <p>1. Upload your website files using:</p>
            <code>scp -r /path/to/your/files/* opc@your-server-ip:/home/opc/</code>
            <p>2. Then run the deployment script again</p>
            <p>3. Point your domain to this server</p>
            <p>4. Set up SSL certificate</p>
        </div>
    </div>
</body>
</html>
EOF
    sudo chown apache:apache /var/www/html/index.html
    echo -e "${BLUE}Please upload your website files using:${NC}"
    echo -e "${YELLOW}scp -r /Users/kofiarcher/Documents/JAM/* opc@\$(curl -s checkip.amazonaws.com):/home/opc/${NC}"
fi

# Create Apache virtual host configuration
echo -e "${BLUE}🌐 Creating Apache configuration...${NC}"
sudo tee /etc/httpd/conf.d/jamconst.conf > /dev/null <<'EOF'
<VirtualHost *:80>
    ServerName jamconst.com
    ServerAlias www.jamconst.com
    DocumentRoot /var/www/html
    
    # Directory permissions
    <Directory "/var/www/html">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    # Security headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
    
    # Enable compression
    <IfModule mod_deflate.c>
        <Location />
            SetOutputFilter DEFLATE
            SetEnvIfNoCase Request_URI \
                \.(?:gif|jpe?g|png|ico|svg)$ no-gzip dont-vary
            SetEnvIfNoCase Request_URI \
                \.(?:exe|t?gz|zip|bz2|sit|rar|pdf)$ no-gzip dont-vary
        </Location>
    </IfModule>
    
    # Enable caching
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType text/css "access plus 1 month"
        ExpiresByType application/javascript "access plus 1 month"
        ExpiresByType text/javascript "access plus 1 month"
        ExpiresByType image/png "access plus 1 month"
        ExpiresByType image/jpg "access plus 1 month"
        ExpiresByType image/jpeg "access plus 1 month"
        ExpiresByType image/gif "access plus 1 month"
        ExpiresByType image/svg+xml "access plus 1 month"
        ExpiresByType image/x-icon "access plus 1 year"
        ExpiresByType application/pdf "access plus 1 month"
        ExpiresByType text/html "access plus 1 day"
    </IfModule>
    
    # Logging
    ErrorLog /var/log/httpd/jamconst_error.log
    CustomLog /var/log/httpd/jamconst_access.log combined
</VirtualHost>
EOF
check_status "Apache configuration creation"

# Test Apache configuration
echo -e "${BLUE}🧪 Testing Apache configuration...${NC}"
sudo httpd -t
check_status "Apache configuration test"

# Restart Apache
echo -e "${BLUE}🔄 Restarting Apache...${NC}"
sudo systemctl restart httpd
check_status "Apache restart"

# Display current status
echo -e "${BLUE}📊 Current status:${NC}"
echo "Apache status: $(sudo systemctl is-active httpd)"
echo "Firewall status: $(sudo systemctl is-active firewalld)"

# Get public IP
echo -e "${BLUE}🌍 Getting public IP...${NC}"
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/ 2>/dev/null || curl -s https://ipinfo.io/ip 2>/dev/null || echo "Could not determine IP")
echo "Your public IP: $PUBLIC_IP"

# Final status check
if sudo systemctl is-active --quiet httpd; then
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
else
    echo -e "${RED}❌ Apache is not running properly${NC}"
    echo "Check logs: sudo journalctl -u httpd -f"
    exit 1
fi

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "${BLUE}1. Test your website:${NC} http://$PUBLIC_IP"
echo -e "${BLUE}2. Point your domain (jamconst.com) to IP:${NC} $PUBLIC_IP"
echo -e "${BLUE}3. Wait for DNS propagation (up to 48 hours)${NC}"
echo -e "${BLUE}4. Set up SSL certificate:${NC}"
echo "   sudo certbot --apache -d jamconst.com -d www.jamconst.com"
echo ""
echo -e "${YELLOW}🔧 USEFUL COMMANDS:${NC}"
echo -e "${BLUE}Check logs:${NC}"
echo "   sudo tail -f /var/log/httpd/jamconst_error.log"
echo "   sudo tail -f /var/log/httpd/jamconst_access.log"
echo ""
echo -e "${BLUE}Restart Apache:${NC}"
echo "   sudo systemctl restart httpd"
echo ""
echo -e "${BLUE}Check Apache status:${NC}"
echo "   sudo systemctl status httpd"
echo ""
echo -e "${BLUE}Upload files from local machine:${NC}"
echo "   scp -r /Users/kofiarcher/Documents/JAM/* opc@$PUBLIC_IP:/home/opc/"
echo "   Then run: sudo cp -r /home/opc/* /var/www/html/ && sudo chown -R apache:apache /var/www/html/"

# Set up automatic SSL renewal (prepare for later)
echo -e "${BLUE}📝 Setting up SSL auto-renewal cron job...${NC}"
(sudo crontab -l 2>/dev/null; echo "0 12 * * * /bin/certbot renew --quiet") | sudo crontab -
check_status "SSL auto-renewal setup"

echo -e "${GREEN}✨ Setup complete! Your server is ready.${NC}"
