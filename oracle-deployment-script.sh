#!/bin/bash

# JAM Construction - Oracle Cloud Deployment Script
# Run this script on your Oracle Cloud instance after initial setup

echo "🚀 Starting JAM Construction website deployment..."

# Update system
echo "📦 Updating system packages..."
sudo dnf update -y

# Install required packages
echo "🔧 Installing Apache and SSL tools..."
sudo dnf install -y httpd certbot python3-certbot-apache firewalld

# Start and enable services
echo "⚡ Starting services..."
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Configure firewall
echo "🔥 Configuring firewall..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

# Create website directory and set permissions
echo "📁 Setting up website directory..."
sudo mkdir -p /var/www/html
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html

# Copy website files (assumes files are in current directory)
echo "📋 Copying website files..."
if [ -f "index.html" ]; then
    sudo cp -r * /var/www/html/
    sudo chown -R apache:apache /var/www/html/
    echo "✅ Website files copied successfully"
else
    echo "❌ No website files found in current directory"
    echo "Please upload your website files first:"
    echo "scp -r /Users/kofiarcher/Documents/JAM/* opc@your-server-ip:/home/opc/"
fi

# Create Apache virtual host configuration
echo "🌐 Creating Apache configuration..."
sudo tee /etc/httpd/conf.d/jamconst.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName jamconst.com
    ServerAlias www.jamconst.com
    DocumentRoot /var/www/html
    
    # Security headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    
    # Enable compression
    LoadModule deflate_module modules/mod_deflate.so
    <Location />
        SetOutputFilter DEFLATE
        SetEnvIfNoCase Request_URI \
            \.(?:gif|jpe?g|png)$ no-gzip dont-vary
        SetEnvIfNoCase Request_URI \
            \.(?:exe|t?gz|zip|bz2|sit|rar)$ no-gzip dont-vary
    </Location>
    
    # Enable caching
    LoadModule expires_module modules/mod_expires.so
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    
    ErrorLog /var/log/httpd/jamconst_error.log
    CustomLog /var/log/httpd/jamconst_access.log combined
</VirtualHost>
EOF

# Restart Apache
echo "🔄 Restarting Apache..."
sudo systemctl restart httpd

# Test Apache configuration
echo "🧪 Testing Apache configuration..."
sudo httpd -t

if [ $? -eq 0 ]; then
    echo "✅ Apache configuration is valid"
else
    echo "❌ Apache configuration has errors"
    exit 1
fi

# Display current status
echo "📊 Current status:"
echo "Apache status: $(sudo systemctl is-active httpd)"
echo "Firewall status: $(sudo systemctl is-active firewalld)"

# Get public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/)
echo "🌍 Your public IP: $PUBLIC_IP"

echo "🎉 Deployment completed!"
echo ""
echo "Next steps:"
echo "1. Point your domain (jamconst.com) to IP: $PUBLIC_IP"
echo "2. Wait for DNS propagation (up to 48 hours)"
echo "3. Run SSL setup: sudo certbot --apache -d jamconst.com -d www.jamconst.com"
echo "4. Test your website at: http://$PUBLIC_IP"
echo ""
echo "For SSL setup after domain is pointed:"
echo "sudo certbot --apache -d jamconst.com -d www.jamconst.com"
echo ""
echo "To check logs:"
echo "sudo tail -f /var/log/httpd/jamconst_error.log"
echo "sudo tail -f /var/log/httpd/jamconst_access.log"