# 🔒 SSL Auto Certificate - Danautoscript

## ✨ New Features Added

### 1. **Auto SSL Certificate** saat Ganti Domain
- ✅ Auto issue SSL certificate dari Let's Encrypt
- ✅ Auto install certificate ke XRAY
- ✅ Auto verify domain & certificate
- ✅ Backup old certificate before change
- ✅ Rollback support if failed

### 2. **SSL Certificate Verification Tool**
- ✅ Check certificate validity
- ✅ Check expiry date
- ✅ Verify domain match
- ✅ Test HTTPS connection
- ✅ Service status check

---

## 🚀 How to Use

### Ganti Domain + Auto SSL

```bash
# Via menu
menu → [8] TOOLS → [3] Ganti Domain + Auto SSL

# Or direct
bash /etc/danautoscript/tools/domain.sh
```

**Process:**
1. Input domain baru
2. Stop services (nginx, xray)
3. Backup old certificate
4. Issue new SSL certificate (Let's Encrypt)
5. Install certificate
6. Update domain files
7. Verify & start services
8. Show certificate info

---

### Verify SSL Certificate

```bash
# Via menu
menu → [8] TOOLS → [6] Verify SSL Certificate

# Or direct
bash /etc/danautoscript/tools/verify-ssl.sh
```

**Checks:**
- ✅ Certificate files exist
- ✅ Domain match
- ✅ Expiry date (days left)
- ✅ Certificate chain
- ✅ NGINX config
- ✅ XRAY config
- ✅ HTTPS accessibility
- ✅ SSL connection test

---

## 📋 Certificate Info Displayed

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         ✅ SSL CERTIFICATE VERIFIED         
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📌 Domain      : yourdomain.com
🔒 Certificate : Valid
🏢 Issuer      : Let's Encrypt Authority X3
📅 Valid Until : Dec 31 23:59:59 2026 GMT
📂 Key File    : /etc/xray/private.key
📂 Cert File   : /etc/xray/cert.crt

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔧 Certificate Files Location

```
/etc/xray/
├── cert.crt          # SSL Certificate
├── private.key       # Private Key
└── domain            # Domain name

~/.acme.sh/
└── yourdomain.com_ecc/  # Certificate backup
```

---

## 🔄 Auto Renewal

Certificate akan auto-renew by acme.sh:
- Cron job otomatis setiap hari
- Renew 30 hari sebelum expired
- Auto restart nginx setelah renew

Check cron:
```bash
crontab -l | grep acme
```

Manual renew:
```bash
~/.acme.sh/acme.sh --renew -d yourdomain.com --ecc --force
```

---

## ⚠️ Troubleshooting

### Issue: Certificate Failed

**Possible causes:**
1. Port 80 not accessible
2. Domain not pointing to VPS IP
3. Firewall blocking

**Fix:**
```bash
# Check port 80
ss -tulpn | grep :80

# Check firewall
ufw status
iptables -L -n | grep 80

# Test domain resolution
nslookup yourdomain.com

# Check DNS propagation
dig yourdomain.com +short
```

### Issue: Certificate Mismatch

**Fix:**
```bash
# Re-issue certificate
menu → Tools → Ganti Domain + Auto SSL
# Input the same domain to re-issue
```

### Issue: Certificate Expired

**Fix:**
```bash
# Manual renew
~/.acme.sh/acme.sh --renew -d yourdomain.com --ecc --force

# Install renewed cert
~/.acme.sh/acme.sh --install-cert \
    -d yourdomain.com --ecc \
    --key-file /etc/xray/private.key \
    --fullchain-file /etc/xray/cert.crt

# Restart services
systemctl restart xray nginx
```

---

## 📝 Before Changing Domain

**Checklist:**
1. ✅ Domain already pointing to VPS IP
2. ✅ Port 80 accessible (for Let's Encrypt validation)
3. ✅ No firewall blocking port 80
4. ✅ DNS propagated (wait 5-10 minutes after DNS change)

**Test DNS:**
```bash
ping yourdomain.com
nslookup yourdomain.com
dig yourdomain.com +short
```

---

## 🎯 Quick Commands

### Issue New Certificate
```bash
bash /etc/danautoscript/tools/domain.sh
```

### Verify Certificate
```bash
bash /etc/danautoscript/tools/verify-ssl.sh
```

### Check Certificate Expiry
```bash
openssl x509 -in /etc/xray/cert.crt -noout -enddate
```

### Test HTTPS
```bash
curl -I https://yourdomain.com
```

### View Certificate Details
```bash
openssl x509 -in /etc/xray/cert.crt -text -noout
```

---

## ✅ Summary

| Feature | Status |
|---------|--------|
| Auto SSL Issue | ✅ |
| Auto Install | ✅ |
| Auto Verify | ✅ |
| Domain Validation | ✅ |
| Expiry Check | ✅ |
| Backup & Rollback | ✅ |
| Auto Renew | ✅ |
| SSL Verification Tool | ✅ |

---

**SSL Certificate management is now fully automated!** 🎉

Just input domain, everything else is automatic.

---

© 2026 GEN - Danautoscript v2.1.1
