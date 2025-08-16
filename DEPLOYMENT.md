# JAM Construction - Deployment Guide

## Automated CI/CD Pipeline

The website now uses GitHub Actions for automated deployment. Simply push to the `main` branch and the site will automatically update.

### How it works:
1. Push changes to the `main` branch
2. GitHub Actions automatically deploys to the server
3. Creates a backup before deployment
4. Sets proper permissions and restarts Apache
5. Verifies the deployment succeeded

### Manual Deployment (Backup Method)

If you need to deploy manually, use the deployment script:

```bash
./deploy_jam.sh
```

## Server Information

- **Server IP**: 163.192.122.38
- **User**: opc
- **SSH Key**: ~/.ssh/Jam_Construction_key
- **Web Directory**: /var/www/html
- **SSL Certificate**: Auto-renewing (Let's Encrypt)

## Website URLs

- **HTTP**: http://163.192.122.38
- **HTTPS**: https://jamconst.com (when domain is configured)

## Useful Commands

### Check deployment logs:
```bash
ssh -i ~/.ssh/Jam_Construction_key opc@163.192.122.38 'sudo tail -f /var/log/httpd/jamconst_error.log'
```

### Rollback to previous version:
```bash
ssh -i ~/.ssh/Jam_Construction_key opc@163.192.122.38 'ls -la /home/opc/website-backup-*'
# Choose a backup and restore:
ssh -i ~/.ssh/Jam_Construction_key opc@163.192.122.38 'sudo cp -r /home/opc/BACKUP_NAME/* /var/www/html/ && sudo chown -R apache:apache /var/www/html/'
```

### Check Apache status:
```bash
ssh -i ~/.ssh/Jam_Construction_key opc@163.192.122.38 'sudo systemctl status httpd'
```

### Check SSL certificate:
```bash
ssh -i ~/.ssh/Jam_Construction_key opc@163.192.122.38 'sudo certbot certificates'
```

## Updating the Website

1. **Make changes** to your files locally
2. **Commit changes** to Git:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```
3. **Push to GitHub**:
   ```bash
   git push origin main
   ```
4. **Watch the deployment** in GitHub Actions tab
5. **Verify the changes** on https://jamconst.com

## Troubleshooting

### If deployment fails:
1. Check GitHub Actions logs
2. Verify server is accessible
3. Check Apache error logs
4. Use manual deployment as backup

### If SSL expires:
- Certificates auto-renew every 60 days
- Manual renewal: `sudo certbot renew`

### File permissions issues:
```bash
ssh -i ~/.ssh/Jam_Construction_key opc@163.192.122.38 'sudo chown -R apache:apache /var/www/html/ && sudo chmod -R 755 /var/www/html/'
```

## GitHub Repository Secrets

The following secrets are configured for automated deployment:

- `SSH_PRIVATE_KEY`: SSH private key for server access
- `SERVER_IP`: 163.192.122.38
- `SERVER_USER`: opc

**Never share these secrets or commit them to the repository.**