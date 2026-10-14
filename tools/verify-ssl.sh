#!/bin/bash
# Verify SSL Certificate - by GEN

# ==========================================
# COLOR
# ==========================================

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}         🔒 SSL CERTIFICATE CHECKER          ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ==========================================
# GET DOMAIN
# ==========================================

if [[ -f /etc/xray/domain ]]; then
    DOMAIN=$(cat /etc/xray/domain)
    echo -e "${BLUE}📌 Domain: ${CYAN}${DOMAIN}${NC}"
else
    echo -e "${RED}❌ Domain file not found!${NC}"
    exit 1
fi

echo ""

# ==========================================
# CHECK CERTIFICATE FILES
# ==========================================

echo -e "${YELLOW}[1/4] Checking certificate files...${NC}"
echo ""

if [[ -f /etc/xray/cert.crt ]]; then
    echo -e " ${GREEN}✔${NC} Certificate: /etc/xray/cert.crt"
else
    echo -e " ${RED}✘${NC} Certificate: NOT FOUND"
    CERT_ERROR=1
fi

if [[ -f /etc/xray/private.key ]]; then
    echo -e " ${GREEN}✔${NC} Private Key: /etc/xray/private.key"
else
    echo -e " ${RED}✘${NC} Private Key: NOT FOUND"
    KEY_ERROR=1
fi

if [[ "$CERT_ERROR" == "1" ]] || [[ "$KEY_ERROR" == "1" ]]; then
    echo ""
    echo -e "${RED}❌ Certificate files missing!${NC}"
    echo -e "${YELLOW}Run: menu → Tools → Ganti Domain (untuk re-issue SSL)${NC}"
    exit 1
fi

# ==========================================
# VERIFY CERTIFICATE
# ==========================================

echo ""
echo -e "${YELLOW}[2/4] Verifying certificate...${NC}"
echo ""

# Get certificate info
CERT_SUBJECT=$(openssl x509 -in /etc/xray/cert.crt -noout -subject 2>/dev/null | sed 's/subject=//')
CERT_ISSUER=$(openssl x509 -in /etc/xray/cert.crt -noout -issuer 2>/dev/null | grep -o "CN=[^,]*" | cut -d= -f2)
CERT_START=$(openssl x509 -in /etc/xray/cert.crt -noout -startdate 2>/dev/null | cut -d= -f2)
CERT_END=$(openssl x509 -in /etc/xray/cert.crt -noout -enddate 2>/dev/null | cut -d= -f2)
CERT_FINGERPRINT=$(openssl x509 -in /etc/xray/cert.crt -noout -fingerprint 2>/dev/null | cut -d= -f2)

# Check if certificate matches domain
CERT_CN=$(openssl x509 -in /etc/xray/cert.crt -noout -subject 2>/dev/null | grep -o "CN=[^,]*" | cut -d= -f2)

if [[ "$CERT_CN" == "$DOMAIN" ]] || [[ "$CERT_CN" == "*.$DOMAIN" ]]; then
    echo -e " ${GREEN}✔${NC} Domain Match: ${GREEN}Valid${NC}"
else
    echo -e " ${RED}✘${NC} Domain Match: ${RED}Mismatch!${NC}"
    echo -e "   Certificate CN: ${CERT_CN}"
    echo -e "   Expected: ${DOMAIN}"
    MATCH_ERROR=1
fi

# Check expiry
CERT_END_EPOCH=$(date -d "$CERT_END" +%s 2>/dev/null)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($CERT_END_EPOCH - $NOW_EPOCH) / 86400 ))

if [[ $DAYS_LEFT -gt 30 ]]; then
    echo -e " ${GREEN}✔${NC} Expiry: ${GREEN}${DAYS_LEFT} days left${NC}"
elif [[ $DAYS_LEFT -gt 7 ]]; then
    echo -e " ${YELLOW}⚠${NC} Expiry: ${YELLOW}${DAYS_LEFT} days left (renew soon)${NC}"
else
    echo -e " ${RED}✘${NC} Expiry: ${RED}${DAYS_LEFT} days left (URGENT!)${NC}"
    EXPIRY_ERROR=1
fi

# Verify certificate chain
if openssl verify /etc/xray/cert.crt &>/dev/null; then
    echo -e " ${GREEN}✔${NC} Chain: ${GREEN}Valid${NC}"
else
    echo -e " ${YELLOW}⚠${NC} Chain: ${YELLOW}Cannot verify (may still work)${NC}"
fi

# ==========================================
# TEST NGINX & XRAY
# ==========================================

echo ""
echo -e "${YELLOW}[3/4] Testing services...${NC}"
echo ""

# Test NGINX
if command -v nginx &> /dev/null; then
    if nginx -t &>/dev/null; then
        echo -e " ${GREEN}✔${NC} NGINX: ${GREEN}Config valid${NC}"
    else
        echo -e " ${RED}✘${NC} NGINX: ${RED}Config error${NC}"
        NGINX_ERROR=1
    fi
    
    if systemctl is-active --quiet nginx; then
        echo -e " ${GREEN}✔${NC} NGINX: ${GREEN}Running${NC}"
    else
        echo -e " ${RED}✘${NC} NGINX: ${RED}Not running${NC}"
        NGINX_ERROR=1
    fi
else
    echo -e " ${YELLOW}⚠${NC} NGINX: Not installed"
fi

# Test XRAY
if command -v xray &> /dev/null; then
    if xray -test -config /etc/xray/config.json &>/dev/null; then
        echo -e " ${GREEN}✔${NC} XRAY: ${GREEN}Config valid${NC}"
    else
        echo -e " ${RED}✘${NC} XRAY: ${RED}Config error${NC}"
        XRAY_ERROR=1
    fi
    
    if systemctl is-active --quiet xray; then
        echo -e " ${GREEN}✔${NC} XRAY: ${GREEN}Running${NC}"
    else
        echo -e " ${RED}✘${NC} XRAY: ${RED}Not running${NC}"
        XRAY_ERROR=1
    fi
else
    echo -e " ${YELLOW}⚠${NC} XRAY: Not installed"
fi

# ==========================================
# TEST SSL CONNECTION
# ==========================================

echo ""
echo -e "${YELLOW}[4/4] Testing SSL connection...${NC}"
echo ""

# Test HTTPS connection
if timeout 5 curl -skI https://${DOMAIN} &>/dev/null; then
    echo -e " ${GREEN}✔${NC} HTTPS: ${GREEN}Accessible${NC}"
else
    echo -e " ${RED}✘${NC} HTTPS: ${RED}Cannot connect${NC}"
    HTTPS_ERROR=1
fi

# Test certificate via openssl
if echo | timeout 5 openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} 2>/dev/null | grep -q "Verify return code: 0"; then
    echo -e " ${GREEN}✔${NC} SSL Verify: ${GREEN}Valid${NC}"
else
    echo -e " ${YELLOW}⚠${NC} SSL Verify: ${YELLOW}Cannot verify (check DNS/firewall)${NC}"
fi

# ==========================================
# SUMMARY
# ==========================================

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}            📋 CERTIFICATE DETAILS            ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${WHITE}Domain        :${NC} ${CYAN}${DOMAIN}${NC}"
echo -e "${WHITE}Subject       :${NC} ${CERT_SUBJECT}"
echo -e "${WHITE}Issuer        :${NC} ${CERT_ISSUER}"
echo -e "${WHITE}Valid From    :${NC} ${CERT_START}"
echo -e "${WHITE}Valid Until   :${NC} ${CERT_END}"
echo -e "${WHITE}Days Left     :${NC} ${DAYS_LEFT} days"
echo -e "${WHITE}Fingerprint   :${NC} ${CERT_FINGERPRINT}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ==========================================
# STATUS
# ==========================================

echo ""

if [[ -z "$CERT_ERROR" ]] && [[ -z "$KEY_ERROR" ]] && [[ -z "$MATCH_ERROR" ]] && [[ -z "$EXPIRY_ERROR" ]] && [[ -z "$NGINX_ERROR" ]] && [[ -z "$XRAY_ERROR" ]]; then
    echo -e "${GREEN}✅ SSL CERTIFICATE: VALID & WORKING${NC}"
else
    echo -e "${RED}❌ SSL CERTIFICATE: HAS ISSUES${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    
    if [[ "$MATCH_ERROR" == "1" ]]; then
        echo -e " • Domain mismatch - Re-issue certificate for ${DOMAIN}"
    fi
    
    if [[ "$EXPIRY_ERROR" == "1" ]]; then
        echo -e " • Certificate expiring soon - Renew now!"
    fi
    
    if [[ "$NGINX_ERROR" == "1" ]] || [[ "$XRAY_ERROR" == "1" ]]; then
        echo -e " • Service error - Check logs: journalctl -u nginx -n 20"
    fi
    
    if [[ "$HTTPS_ERROR" == "1" ]]; then
        echo -e " • HTTPS not accessible - Check firewall/DNS"
    fi
    
    echo ""
    echo -e "${YELLOW}To fix: menu → Tools → Ganti Domain${NC}"
fi

echo ""

read -n 1 -s -r -p "Tekan tombol apa saja untuk kembali..."

menu
