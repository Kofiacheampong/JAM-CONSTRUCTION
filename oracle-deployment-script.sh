#!/bin/bash
# JAM Construction - Oracle Linux Deployment Script
# Specifically designed for Oracle Linux on Oracle Cloud

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 JAM Construction - Oracle Linux Deployment${NC}"
echo -e "${BLUE}Detected OS: Oracle Linux${NC}"

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1 successful${NC}"
    else
        echo -e "${RED}❌ $1 failed${NC}"
        exit 1
    fi
}

# Check Oracle Linux version
echo -e "${BLUE}📋 Checking Oracle Linux version...${NC}"
cat /etc/oracle-release 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME

# Update system
echo -e "${BLUE}📦 Updating system packages...${NC}"
sudo dnf update -y
check_status "System update"

# Enable Oracle Linux repositories
echo -e "${BLUE}📦 Enabling Oracle Linux repositories...${NC}"
sudo dnf config-manager --enable ol9_developer_EPEL 2>/dev/null || \
sudo dnf config-manager --enable ol8_developer_EPEL 2>/dev/null || \
echo "EPEL repository may need manual setup"

# Alternative: Install EPEL release package
echo -e "${BLUE}📦 Installing EPEL for Oracle Linux...${NC}"
sudo dnf install -y oracle-epel-release-el9 2>/dev/null || \
sudo dnf install -y oracle-epel-release-el8 2>/dev/null || \
sudo dnf install -y epel-release
check_status "EPEL repository setup"

# Update package cache after EPEL
echo -e "${BLUE}🔄 Updating package cache...${NC}"
sudo dnf makecache

# Install Apache and modules
echo -e "${BLUE}🌐 Installing Apache (httpd) and modules...${NC}"
sudo dnf install -y httpd mod_ssl
check_status "Apache installation"

# Note: mod_headers, mod_deflate, mod_expires are built into httpd on Oracle Linux
echo -e "${GREEN}✅ Apache modules (headers, deflate, expires) are built-in${NC}"

# Install Certbot (try different approaches for Oracle Linux)
echo -e "${BLUE}🔐 Installing Certbot...${NC}"
sudo dnf install -y certbot python3-certbot-apache 2>/dev/null || \
sudo dnf install -y snapd && sudo systemctl enable --now snapd && sudo snap install --classic certbot 2>/dev/null || \
echo -e "${YELLOW}⚠️ Certbot installation may need manual setup later${NC}"

# Install firewalld if not present
echo -e "${BLUE}🔥 Ensuring firewall is installed...${NC}"
sudo dnf install -y firewalld
check_status "Firewall installation"

# Start and enable Apache
echo -e "${BLUE}⚡ Starting Apache service...${NC}"
sudo systemctl start httpd
check_status "Apache start"

sudo systemctl enable httpd
check_status "Apache enable"

# Start and enable firewalld
echo -e "${BLUE}🔥 Starting firewall service...${NC}"
sudo systemctl start firewalld
check_status "Firewall start"

sudo systemctl enable firewalld
check_status "Firewall enable"

# Configure firewall for Oracle Linux
echo -e "${BLUE}🔥 Configuring firewall for web services...${NC}"
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh

# Oracle Cloud specific: Open ports explicitly
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=22/tcp

sudo firewall-cmd --reload
check_status "Firewall configuration"

# Create website directory structure
echo -e "${BLUE}📁 Setting up website directory structure...${NC}"
sudo mkdir -p /var/www/html/jamconst
sudo mkdir -p /var/log/httpd

# Set proper ownership for Oracle Linux (apache user and group)
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
check_status "Directory setup"

# Handle website files
echo -e "${BLUE}📋 Setting up website files...${NC}"
if [ -f "index.html" ]; then
    sudo cp -r * /var/www/html/
    sudo chown -R apache:apache /var/www/html/
    sudo chmod -R 755 /var/www/html/
    echo -e "${GREEN}✅ Website files copied successfully${NC}"
elif [ -d "/home/opc/website" ] || [ -f "/home/opc/index.html" ]; then
    sudo cp -r /home/opc/* /var/www/html/ 2>/dev/null
    sudo chown -R apache:apache /var/www/html/
    sudo chmod -R 755 /var/www/html/
    echo -e "${GREEN}✅ Website files copied from /home/opc/${NC}"
else
    echo -e "${YELLOW}⚠️ Creating temporary JAM Construction page...${NC}"
    
    # Create professional temporary page
    sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>JAM Construction - Oracle Cloud Server</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container { 
            background: white; 
            padding: 3rem; 
            border-radius: 20px; 
            box-shadow: 0 25px 50px rgba(0,0,0,0.15);
            text-align: center;
            max-width: 600px;
            width: 100%;
        }
        .logo { 
            font-size: 3rem; 
            color: #333; 
            margin-bottom: 1rem;
        }
        h1 { 
            color: #333; 
            margin-bottom: 1rem;
            font-size: 2.5rem;
            font-weight: 300;
        }
        .status { 
            color: #28a745; 
            font-weight: bold; 
            font-size: 1.3rem;
            margin-bottom: 1.5rem;
            padding: 1rem;
            background: #d4edda;
            border-radius: 8px;
            border: 1px solid #c3e6cb;
        }
        .info { 
            color: #666; 
            line-height: 1.6; 
            margin-bottom: 2rem;
            font-size: 1.1rem;
        }
        .server-info {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 12px;
            margin-top: 2rem;
            text-align: left;
        }
        .server-info h3 {
            color: #495057;
            margin-bottom: 1rem;
        }
        .info-grid {
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 0.5rem;
            font-family: monospace;
            font-size: 0.9rem;
        }
        .info-label {
            font-weight: bold;
            color: #6c757d;
        }
        code {
            background: #e9ecef;
            padding: 0.3rem 0.6rem;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            color: #495057;
        }
        .instructions {
            background: linear-gradient(145deg, #f1f3f4, #e8eaed);
            padding: 2rem;
            border-radius: 12px;
            margin-top: 2rem;
            text-align: left;
        }
        .step {
            margin-bottom: 1rem;
            padding-left: 2rem;
            position: relative;
        }
        .step::before {
            content: "→";
            position: absolute;
            left: 0;
            color: #667eea;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🏗️</div>
        <h1>JAM Construction</h1>
        <div class="status">✅ Oracle Linux Server is Running!</div>
        <div class="info">
            Your Apache web server is successfully configured and running on Oracle Cloud Infrastructure.
        </div>
        
        <div class="server-info">
            <h3>📊 Server Information</h3>
            <div class="info-grid">
                <span class="info-label">OS:</span>
                <span>Oracle Linux ($(cat /etc/oracle-release 2>/dev/null | cut -d' ' -f1-3 || echo 'Oracle Linux'))</span>
                <span class="info-label">Web Server:</span>
                <span>Apache HTTP Server</span>
                <span class="info-label">Server Time:</span>
                <span>$(date)</span>
                <span class="info-label">Status:</span>
                <span style="color: #28a745;">🟢 Online and Ready</span>
            </div>
        </div>
        
        <div class="instructions">
            <h3>📋 Next Steps to Deploy Your Website:</h3>
            
            <div class="step">
                <strong>Upload your files:</strong><br>
                <code>scp -r /Users/kofiarcher/Documents/JAM/* opc@YOUR-SERVER-IP:/home/opc/</code>
            </div>
            
            <div class="step">
                <strong>Deploy the files:</strong><br>
                <code>sudo cp -r /home/opc/* /var/www/html/</code><br>
                <code>sudo chown -R apache:apache /var/www/html/</code>
            </div>
            
            <div class="step">
                <strong>Point your domain:</strong><br>
                Configure jamconst.com DNS to point to this server
            </div>
            
            <div class="step">
                <strong>Set up SSL:</strong><br>
                <code>sudo certbot --apache -d jamconst.com -d www.jamconst.com</code>
            </div>
        </div>
    </div>
</body>
</html>
EOF
    sudo chown apache:apache /var/www/html/index.html
fi

# Create Apache virtual host configuration for Oracle Linux
echo -e "${BLUE}🌐 Creating Apache virtual host configuration...${NC}"
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
        
        # Security settings for Oracle Linux
        <FilesMatch "^\.">
            Require all denied
        </FilesMatch>
    </Directory>
    
    # Security headers
    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
        Header always set Referrer-Policy "strict-origin-when-cross-origin"
    </IfModule>
    
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
        ExpiresByType text/html "access plus 1 day"
    </IfModule>
    
    # Logging
    ErrorLog /var/log/httpd/jamconst_error.log
    CustomLog /var/log/httpd/jamconst_access.log combined
</VirtualHost>
EOF
check_status "Virtual host configuration"

# Oracle Linux specific: Check SELinux and adjust if needed
echo -e "${BLUE}🔐 Checking SELinux configuration...${NC}"
if command -v getenforce >/dev/null 2>&1; then
    SELINUX_STATUS=$(getenforce)
    echo "SELinux status: $SELINUX_STATUS"
    
    if [ "$SELINUX_STATUS" = "Enforcing" ]; then
        echo -e "${YELLOW}⚠️ SELinux is enforcing. Setting web content context...${NC}"
        sudo setsebool -P httpd_can_network_connect 1
        sudo restorecon -Rv /var/www/html/
        check_status "SELinux context adjustment"
    fi
fi

# Test Apache configuration
echo -e "${BLUE}🧪 Testing Apache configuration...${NC}"
sudo httpd -t
check_status "Apache configuration test"

# Restart Apache with new configuration
echo -e "${BLUE}🔄 Restarting Apache...${NC}"
sudo systemctl restart httpd
check_status "Apache restart"

# Final status checks
echo -e "${BLUE}📊 Checking service status...${NC}"
echo "Apache status: $(sudo systemctl is-active httpd)"
echo "Firewall status: $(sudo systemctl is-active firewalld)"

# Get public IP
echo -e "${BLUE}🌍 Getting public IP address...${NC}"
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/ 2>/dev/null || curl -s https://ipinfo.io/ip 2>/dev/null || echo "Could not determine IP")

# Final success message
if sudo systemctl is-active --quiet httpd; then
    echo -e "${GREEN}"
    echo "=========================================="
    echo "🎉 DEPLOYMENT SUCCESSFUL!"
    echo "=========================================="
    echo -e "${NC}"
    echo -e "${BLUE}🌐 Your website is live at: http://$PUBLIC_IP${NC}"
    echo -e "${BLUE}📧 Server IP Address: $PUBLIC_IP${NC}"
    echo ""
    echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
    echo -e "${GREEN}1.${NC} Test your server: curl http://$PUBLIC_IP or open in browser"
    echo -e "${GREEN}2.${NC} Upload your website files (if not done yet):"
    echo "   scp -r /Users/kofiarcher/Documents/JAM/* opc@$PUBLIC_IP:/home/opc/"
    echo "   sudo cp -r /home/opc/* /var/www/html/ && sudo chown -R apache:apache /var/www/html/"
    echo -e "${GREEN}3.${NC} Point jamconst.com DNS to: $PUBLIC_IP"
    echo -e "${GREEN}4.${NC} Set up SSL certificate (after DNS propagation):"
    echo "   sudo certbot --apache -d jamconst.com -d www.jamconst.com"
    echo ""
    echo -e "${YELLOW}🔧 USEFUL COMMANDS:${NC}"
    echo "Check logs: sudo tail -f /var/log/httpd/jamconst_error.log"
    echo "Restart Apache: sudo systemctl restart httpd"
    echo "Check status: sudo systemctl status httpd"
    
else
    echo -e "${RED}❌ Apache is not running properly${NC}"
    echo "Check the logs:"
    echo "sudo journalctl -u httpd -f"
    echo "sudo tail -f /var/log/httpd/error_log"
    exit 1
fi

echo -e "${GREEN}✨ Oracle Linux deployment complete!${NC}"