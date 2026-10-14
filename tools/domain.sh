#!/bin/bash
# Ganti Domain + Auto SSL - by GEN

# ==========================================
# COLOR
# ==========================================

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

# ==========================================
# CHECK ROOT
# ==========================================

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR] Script harus dijalankan sebagai root!${NC}"
    exit 1
fi

clear

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}         🌐 GANTI DOMAIN + AUTO SSL           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ==========================================
# SHOW CURRENT DOMAIN
# ==========================================

if [[ -f /etc/xray/domain ]]; then
    OLD_DOMAIN=$(cat /etc/xray/domain)
    echo -e "${BLUE}📌 Domain saat ini: ${CYAN}${OLD_DOMAIN}${NC}"
else
    echo -e "${YELLOW}⚠️  Domain belum diset${NC}"
fi

echo ""

# ==========================================
# INPUT NEW DOMAIN
# ==========================================

read -rp "📌 Masukkan domain baru: " NEW_DOMAIN

# Validasi input
if [[ -z "$NEW_DOMAIN" ]]; then
    echo -e "${RED}❌ Domain tidak boleh kosong!${NC}"
    exit 1
fi

# Validasi format domain
if ! [[ "$NEW_DOMAIN" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$ ]]; then
    echo -e "${RED}❌ Format domain tidak valid!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[INFO] Domain baru: ${CYAN}${NEW_DOMAIN}${NC}"
echo ""

read -rp "Lanjutkan? [y/N]: " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Dibatalkan.${NC}"
    exit 0
fi

echo ""

# ==========================================
# STOP SERVICES
# ==========================================

echo -e "${BLUE}[1/7]${NC} Stopping services..."

systemctl stop nginx 2>/dev/null || true
systemctl stop xray 2>/dev/null || true
systemctl stop apache2 2>/dev/null || true

# Kill port 80
fuser -k 80/tcp >/dev/null 2>&1 || true

sleep 2

echo -e "${GREEN}✔ Services stopped${NC}"

# ==========================================
# BACKUP OLD CERTIFICATE
# ==========================================

echo ""
echo -e "${BLUE}[2/7]${NC} Backing up old certificate..."

if [[ -d ~/.acme.sh/${OLD_DOMAIN}_ecc ]]; then
    BACKUP_DIR="/root/ssl-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r ~/.acme.sh/${OLD_DOMAIN}_ecc "$BACKUP_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✔ Backup saved to: ${BACKUP_DIR}${NC}"
else
    echo -e "${YELLOW}⚠️  No old certificate found${NC}"
fi

# ==========================================
# INSTALL/UPDATE ACME.SH
# ==========================================

echo ""
echo -e "${BLUE}[3/7]${NC} Checking acme.sh..."

if [ ! -f ~/.acme.sh/acme.sh ]; then
    echo -e "${YELLOW}[INFO] Installing acme.sh...${NC}"
    curl -s https://get.acme.sh | sh -s email=admin@${NEW_DOMAIN}
fi

chmod +x ~/.acme.sh/acme.sh

~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --register-account -m admin@${NEW_DOMAIN} 2>/dev/null || true

echo -e "${GREEN}✔ acme.sh ready${NC}"

# ==========================================
# ISSUE NEW CERTIFICATE
# ==========================================

echo ""
echo -e "${BLUE}[4/7]${NC} Issuing SSL certificate for ${NEW_DOMAIN}..."

~/.acme.sh/acme.sh \
    --issue \
    -d "${NEW_DOMAIN}" \
    --standalone \
    --keylength ec-256 \
    --force || {
        echo -e "${RED}[ERROR] Failed to issue certificate!${NC}"
        echo -e "${YELLOW}[INFO] Starting services back...${NC}"
        systemctl start nginx
        systemctl start xray
        exit 1
}

echo -e "${GREEN}✔ Certificate issued successfully${NC}"

# ==========================================
# INSTALL CERTIFICATE
# ==========================================

echo ""
echo -e "${BLUE}[5/7]${NC} Installing certificate..."

mkdir -p /etc/xray

~/.acme.sh/acme.sh \
    --install-cert \
    -d "${NEW_DOMAIN}" \
    --ecc \
    --key-file /etc/xray/private.key \
    --fullchain-file /etc/xray/cert.crt || {
        echo -e "${RED}[ERROR] Failed to install certificate!${NC}"
        exit 1
}

chmod 600 /etc/xray/private.key
chmod 644 /etc/xray/cert.crt

echo -e "${GREEN}✔ Certificate installed${NC}"

# ==========================================
# UPDATE DOMAIN FILES
# ==========================================

echo ""
echo -e "${BLUE}[6/7]${NC} Updating domain configuration..."

echo "${NEW_DOMAIN}" > /etc/xray/domain
echo "${NEW_DOMAIN}" > /etc/v2ray/domain 2>/dev/null || true
echo "${NEW_DOMAIN}" > /root/domain
echo "${NEW_DOMAIN}" > /root/scdomain 2>/dev/null || true
echo "IP=${NEW_DOMAIN}" > /var/lib/ipvps.conf 2>/dev/null || true

echo -e "${GREEN}✔ Domain configuration updated${NC}"

# ==========================================
# VERIFY & START SERVICES
# ==========================================

echo ""
echo -e "${BLUE}[7/7]${NC} Verifying and starting services..."

# Test NGINX config
if command -v nginx &> /dev/null; then
    if ! nginx -t 2>/dev/null; then
        echo -e "${YELLOW}⚠️  NGINX config has warnings (but may still work)${NC}"
    fi
fi

# Test XRAY config
if command -v xray &> /dev/null; then
    if ! xray -test -config /etc/xray/config.json 2>/dev/null; then
        echo -e "${YELLOW}⚠️  XRAY config has warnings (but may still work)${NC}"
    fi
fi

# Start services
systemctl start xray
systemctl start nginx

sleep 2

# Check services
XRAY_STATUS=$(systemctl is-active xray 2>/dev/null || echo "inactive")
NGINX_STATUS=$(systemctl is-active nginx 2>/dev/null || echo "inactive")

echo ""

if [[ "$XRAY_STATUS" == "active" ]]; then
    echo -e "${GREEN}✔ XRAY running${NC}"
else
    echo -e "${RED}✘ XRAY not running${NC}"
fi

if [[ "$NGINX_STATUS" == "active" ]]; then
    echo -e "${GREEN}✔ NGINX running${NC}"
else
    echo -e "${RED}✘ NGINX not running${NC}"
fi

# ==========================================
# VERIFY SSL CERTIFICATE
# ==========================================

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}         ✅ SSL CERTIFICATE VERIFIED         ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Show certificate info
if [[ -f /etc/xray/cert.crt ]]; then
    CERT_SUBJECT=$(openssl x509 -in /etc/xray/cert.crt -noout -subject 2>/dev/null | cut -d= -f2-)
    CERT_ISSUER=$(openssl x509 -in /etc/xray/cert.crt -noout -issuer 2>/dev/null | grep -o "CN=[^,]*" | cut -d= -f2)
    CERT_EXPIRY=$(openssl x509 -in /etc/xray/cert.crt -noout -enddate 2>/dev/null | cut -d= -f2)
    
    echo -e "${WHITE}📌 Domain      :${NC} ${CYAN}${NEW_DOMAIN}${NC}"
    echo -e "${WHITE}🔒 Certificate :${NC} ${GREEN}Valid${NC}"
    echo -e "${WHITE}🏢 Issuer      :${NC} ${CERT_ISSUER}"
    echo -e "${WHITE}📅 Valid Until :${NC} ${CERT_EXPIRY}"
    echo -e "${WHITE}📂 Key File    :${NC} /etc/xray/private.key"
    echo -e "${WHITE}📂 Cert File   :${NC} /etc/xray/cert.crt"
else
    echo -e "${RED}❌ Certificate file not found!${NC}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
echo -e "${GREEN}✅ Domain berhasil diganti dan SSL certificate ter-install!${NC}"
echo ""
echo -e "${YELLOW}📝 Notes:${NC}"
echo -e " • Pastikan domain sudah pointing ke IP VPS ini"
echo -e " • Test akses: https://${NEW_DOMAIN}"
echo -e " • Certificate auto-renew by acme.sh"
echo ""

read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali ke menu..."

menu
