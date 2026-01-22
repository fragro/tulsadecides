# TulsaDecides Production TODO

## Critical - Before Launch

### [ ] Email Configuration
- Update SMTP from personal Gmail to official TulsaDecides email
- Files to update:
  - /etc/systemd/system/decidim.service (SMTP_USERNAME, SMTP_PASSWORD)
  - /etc/systemd/system/sidekiq.service (SMTP_USERNAME, SMTP_PASSWORD)
  - /home/decidim/decidim_app/config/environments/production.rb
- Run: systemctl daemon-reload && systemctl restart decidim sidekiq

### [ ] SMS Verification Testing
- Twilio credentials are configured
- Test SMS verification flow end-to-end
- Verify Twilio account has sufficient balance
- Test with real phone number

---

## High Priority - Security

### [ ] Run as Non-Root User
- Currently running as root (bad practice)
- Create dedicated decidim user
- Update file ownership and systemd services

### [ ] Secure Environment Variables
- Move sensitive vars from systemd services to .env file
- Use EnvironmentFile= directive instead of inline Environment=

### [ ] Change Default Admin Password
- System admin: https://tulsadecides.org/system
- Change from documented default password

### [ ] Fail2ban
- Install and configure fail2ban for SSH brute-force protection

---

## Medium Priority - Reliability

### [ ] Offsite Backups
- Database backups are local only (/var/backups/postgresql/)
- Configure offsite backup (S3, Backblaze, rsync to remote)
- Test backup restoration procedure

### [ ] Log Rotation
- Verify logrotate configured for production.log and nginx logs

### [ ] Monitoring and Alerting
- Set up uptime monitoring (UptimeRobot, Pingdom, etc.)
- Consider error tracking (Sentry, Rollbar)

### [ ] SSL Certificate Monitoring
- Current cert expires: 2026-04-04
- Auto-renewal enabled via certbot timer
- Set up alert for renewal failures

---

## Low Priority - Enhancements

### [ ] Cloud Storage (Optional)
- Currently using local disk storage
- Consider S3/GCS for uploaded files

### [ ] CDN (Optional)
- Consider CloudFlare for DDoS protection and caching

### [ ] Rate Limiting
- Add rate limiting to Nginx

### [ ] HTTP Security Headers
- Add security headers to Nginx

---

## Completed

### [x] Firewall (UFW)
- Enabled with ports 22, 80, 443 allowed

### [x] Background Jobs (Sidekiq)
- Sidekiq 7.3.10 installed and running
- Connected to Redis at localhost:6379
- Systemd service: /etc/systemd/system/sidekiq.service
- Health check: bundle exec rake sidekiq:health
- Test job: bundle exec rake sidekiq:test

### [x] Social SEO
- Open Graph meta tags added
- Twitter Card meta tags added

---

## Health Check Commands

```bash
# Check all services
systemctl status decidim sidekiq redis-server postgresql nginx

# Check Sidekiq health
cd /home/decidim/decidim_app && RAILS_ENV=production bundle exec rake sidekiq:health

# Test Sidekiq job processing
cd /home/decidim/decidim_app && RAILS_ENV=production bundle exec rake sidekiq:test

# View Sidekiq logs
journalctl -u sidekiq -f

# Check firewall
ufw status
```

---

## Current Status Summary

| Component | Status |
|-----------|--------|
| SSL/HTTPS | ✅ Working (expires Apr 4) |
| Database | ✅ PostgreSQL 16 running |
| DB Backups | ✅ Daily at 3am, local only |
| Redis | ✅ Running |
| Nginx | ✅ Configured |
| Sidekiq | ✅ Running |
| Firewall | ✅ Active (22, 80, 443) |
| SMTP | ⚠️ Using personal Gmail |
| SMS | ⚠️ Needs testing |
| Monitoring | ❌ None |

---

*Last updated: January 2026*
