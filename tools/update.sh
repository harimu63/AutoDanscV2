#!/bin/bash
# Auto Update Script - Danautoscript
# By GEN

clear

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
# CONFIG
# ==========================================

GITHUB_USER="harimu63"
GITHUB_REPO="AutoDanscV2"
GITHUB_BRANCH="main"
GITHUB_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
INSTALL_DIR="/root/danautoscript"
BACKUP_DIR="/root/danautoscript-backup-$(date +%Y%m%d-%H%M%S)"

# ==========================================
# HEADER
# ==========================================

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}    🔄 DANAUTOSCRIPT AUTO UPDATE${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ==========================================
# CHECK ROOT
# ==========================================

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR] Script harus dijalankan sebagai root!${NC}"
    exit 1
fi

# ==========================================
# CHECK INTERNET
# ==========================================

echo -e "${BLUE}[1/6]${NC} Checking internet connection..."

if ! ping -c 1 google.com &> /dev/null; then
    echo -e "${RED}[ERROR] No internet connection!${NC}"
    exit 1
fi

echo -e "${GREEN}✔ Internet connected${NC}"
sleep 1

# ==========================================
# CHECK GIT
# ==========================================

echo ""
echo -e "${BLUE}[2/6]${NC} Checking git installation..."

if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}[INFO] Installing git...${NC}"
    apt update -y
    apt install -y git
fi

echo -e "${GREEN}✔ Git ready${NC}"
sleep 1

# ==========================================
# BACKUP CURRENT
# ==========================================

echo ""
echo -e "${BLUE}[3/6]${NC} Backing up current installation..."

if [ -d "$INSTALL_DIR" ]; then
    cp -r "$INSTALL_DIR" "$BACKUP_DIR"
    echo -e "${GREEN}✔ Backup saved to: ${BACKUP_DIR}${NC}"
else
    echo -e "${YELLOW}[WARN] No existing installation found${NC}"
fi

sleep 1

# ==========================================
# FETCH UPDATES
# ==========================================

echo ""
echo -e "${BLUE}[4/6]${NC} Fetching updates from GitHub..."

cd /root || exit

# Remove old installation
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "${INSTALL_DIR}"
fi

# Clone latest version
if git clone "$GITHUB_URL" "$INSTALL_DIR"; then
    echo -e "${GREEN}✔ Successfully downloaded latest version${NC}"
else
    echo -e "${RED}[ERROR] Failed to download updates!${NC}"
    echo -e "${YELLOW}[INFO] Restoring backup...${NC}"
    
    if [ -d "$BACKUP_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        cp -r "$BACKUP_DIR" "$INSTALL_DIR"
        echo -e "${GREEN}✔ Backup restored${NC}"
    fi
    
    exit 1
fi

sleep 1

# ==========================================
# UPDATE FILES
# ==========================================

echo ""
echo -e "${BLUE}[5/6]${NC} Updating system files..."

cd "$INSTALL_DIR" || exit

# Update menu files
echo -e "${CYAN}→${NC} Updating menu files..."

cp -f ssh/m-ssh /usr/bin/ 2>/dev/null
cp -f xray/m-vmess /usr/bin/ 2>/dev/null
cp -f xray/m-vless /usr/bin/ 2>/dev/null
cp -f xray/m-trojan /usr/bin/ 2>/dev/null
cp -f xray/m-ssws /usr/bin/ 2>/dev/null
cp -f wg/m-wg /usr/bin/ 2>/dev/null
cp -f udp/m-zivpn /usr/bin/ 2>/dev/null
cp -f tools/tools-menu /usr/bin/ 2>/dev/null
cp -f menu.sh /usr/bin/menu 2>/dev/null

# Update scripts in /etc/danautoscript/
echo -e "${CYAN}→${NC} Updating script files..."

mkdir -p /etc/danautoscript/{ssh,xray,wg,udp,tools}

cp -rf ssh/* /etc/danautoscript/ssh/ 2>/dev/null
cp -rf xray/* /etc/danautoscript/xray/ 2>/dev/null
cp -rf wg/* /etc/danautoscript/wg/ 2>/dev/null
cp -rf udp/* /etc/danautoscript/udp/ 2>/dev/null
cp -rf tools/* /etc/danautoscript/tools/ 2>/dev/null

# Set permissions
chmod +x /usr/bin/menu
chmod +x /usr/bin/m-*
chmod +x /usr/bin/tools-menu
chmod +x /etc/danautoscript/*/*.sh

echo -e "${GREEN}✔ Files updated successfully${NC}"
sleep 1

# ==========================================
# VERSION CHECK
# ==========================================

echo ""
echo -e "${BLUE}[6/6]${NC} Checking version..."

if [ -f "$INSTALL_DIR/version.txt" ]; then
    NEW_VERSION=$(cat "$INSTALL_DIR/version.txt")
    echo -e "${GREEN}✔ Updated to version: ${NEW_VERSION}${NC}"
else
    echo -e "${GREEN}✔ Updated to latest version${NC}"
fi

sleep 1

# ==========================================
# CLEANUP
# ==========================================

echo ""
echo -e "${YELLOW}[INFO] Cleaning up...${NC}"

# Optional: Remove backup if update successful
read -p "Remove backup? [y/N]: " remove_backup

if [[ "$remove_backup" =~ ^[Yy]$ ]]; then
    rm -rf "$BACKUP_DIR"
    echo -e "${GREEN}✔ Backup removed${NC}"
else
    echo -e "${CYAN}[INFO] Backup kept at: ${BACKUP_DIR}${NC}"
fi

# ==========================================
# FINISH
# ==========================================

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    ✅ UPDATE COMPLETED!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo ""
echo -e "${YELLOW}📝 Update Summary:${NC}"
echo -e " • Source: github.com/${GITHUB_USER}/${GITHUB_REPO}"
echo -e " • Install Dir: ${INSTALL_DIR}"
echo -e " • Backup: ${BACKUP_DIR}"
echo ""
echo -e "${GREEN}Run 'menu' to see changes${NC}"
echo ""

read -n 1 -s -r -p "Press any key to continue..."

menu
