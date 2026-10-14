#!/bin/bash

# GEN XRAY PANEL

# ================= COLOR =================
PANEL_VERSION="v2.1.1"

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

CONFIG="/etc/xray/config.json"
LOG="/var/log/xray/access.log"

# ================= ANIMATION =================

loading() {
local text="$1"

echo -ne "${CYAN}➜ ${text}${NC}"

for i in {1..3}; do
    echo -ne "."
    sleep 0.35
done

echo ""


}

type_text() {
    local delay="${2:-0.02}"

    while IFS= read -r -n1 char; do
        printf "%s" "$char"
        sleep "$delay"
    done

    echo
}

# ================= SYSTEM INFO =================

IP=$(curl -s ipv4.icanhazip.com)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "N/A")

ISP=$(curl -s --max-time 3 ipinfo.io/org | cut -d " " -f2-)
[[ -z "$ISP" ]] && ISP="Unknown"

UPTIME=$(uptime -p | sed 's/up //')
TIME=$(date "+%d-%m-%Y %H:%M:%S")

OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4"%"}')

RAM=$(free -m | awk 'NR==2{printf "%sMB / %sMB",$3,$2}')

DISK=$(df -h / | awk 'NR==2{print $3 "/" $2}')

# ================= NETWORK =================

IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')

# Check if vnstat database exists, if not create it
if [[ ! -z "$IFACE" ]]; then
    if ! vnstat -i "$IFACE" &>/dev/null; then
        vnstat -i "$IFACE" --create &>/dev/null
        sleep 1
    fi
fi

MONTH_NAME=$(date +"%b %Y")

TODAY=$(vnstat -i "$IFACE" 2>/dev/null | grep "today" | awk '{print $8" "$9}')

YESTERDAY=$(vnstat -i "$IFACE" 2>/dev/null | grep "yesterday" | awk '{print $8" "$9}')

MONTH=$(vnstat -i "$IFACE" -m 2>/dev/null | grep "$MONTH_NAME" | awk '{print $3" "$4}')

TOTAL_BW=$(vnstat -i "$IFACE" 2>/dev/null | grep "estimated" | awk '{print $5" "$6}')

[[ -z "$TODAY" ]] && TODAY="0 B"
[[ -z "$YESTERDAY" ]] && YESTERDAY="0 B"
[[ -z "$MONTH" ]] && MONTH="0 B"
[[ -z "$TOTAL_BW" ]] && TOTAL_BW="0 B"

# ================= STATUS =================

XRAY=$(systemctl is-active xray)

if [[ $XRAY == "active" ]]; then
XRAY="${GREEN}🟢 ONLINE${NC}"
else
XRAY="${RED}🔴 OFFLINE${NC}"
fi

NGINX=$(systemctl is-active nginx)

if [[ $NGINX == "active" ]]; then
NGINX="${GREEN}🟢 ONLINE${NC}"
else
NGINX="${RED}🔴 OFFLINE${NC}"
fi

WG=$(systemctl is-active wg-quick@wg0)

if [[ $WG == "active" ]]; then
WG="${GREEN}🟢 ONLINE${NC}"
else
WG="${RED}🔴 OFFLINE${NC}"
fi

UDPCUSTOM=$(systemctl is-active udp-custom)

if [[ $UDPCUSTOM == "active" ]]; then
    UDPCUSTOM="${GREEN}🟢 ONLINE${NC}"
else
    UDPCUSTOM="${RED}🔴 OFFLINE${NC}"
fi

DROPBEARWS=$(systemctl is-active dropbear-ws)

if [[ $DROPBEARWS == "active" ]]; then
DROPBEARWS="${GREEN}🟢 ONLINE${NC}"
else
DROPBEARWS="${RED}🔴 OFFLINE${NC}"
fi

STUNNELWS=$(systemctl is-active stunnel-ws)

if [[ $STUNNELWS == "active" ]]; then
    STUNNELWS="${GREEN}🟢 ONLINE${NC}"
else
    STUNNELWS="${RED}🔴 OFFLINE${NC}"
fi

DROPBEAR=$(systemctl is-active dropbear)

if [[ $DROPBEAR == "active" ]]; then
    DROPBEAR="${GREEN}🟢 ONLINE${NC}"
else
    DROPBEAR="${RED}🔴 OFFLINE${NC}"
fi

# ================= USER COUNT =================

VMESS=$(jq '[.inbounds[] | select(.tag=="vmess-ws-tls").settings.clients[]] | length' $CONFIG 2>/dev/null)

VLESS=$(jq '[.inbounds[] | select(.tag=="vless-ws-tls").settings.clients[]] | length' $CONFIG 2>/dev/null)

TROJAN=$(jq '[.inbounds[] | select(.tag=="trojan-ws-tls").settings.clients[]] | length' $CONFIG 2>/dev/null)

SSWS=$(jq '[.inbounds[] | select(.tag=="ssws-ws-tls").settings.clients[]] | length' $CONFIG 2>/dev/null)

SSH_USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)

TOTAL=$((VMESS + VLESS + TROJAN + SSWS + SSH_USER))

ONLINE=$(tail -n 500 /var/log/xray/access.log 2>/dev/null | 
grep -Eo 'tcp:[0-9]+.[0-9]+.[0-9]+.[0-9]+' | 
cut -d':' -f2 | sort -u | wc -l)

# ===== INIT =====

clear

echo -ne "${RED}"
printf "⚡ Loading DANAUTOSCRIPT PANEL ⚡" | type_text
echo -e "${NC}"

loading "Loading System Modules"
loading "Checking Services"
loading "Reading Traffic Database"

echo ""
echo -e "${GREEN}✔ System Ready!${NC}"

sleep 1
clear

# ================= HEADER =================

echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
echo -e "${CYAN}┃${WHITE}          ⚡ DANAUTOSCRIPT PANEL ⚡         ${CYAN}┃${NC}"
echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"

# ================= SYSTEM INFO =================

echo -e "${YELLOW}┌──────────────── SYSTEM INFO ────────────────┐${NC}"

printf " ${WHITE}IP VPS      ${NC}: %-25s\n" "$IP"
printf " ${WHITE}DOMAIN      ${NC}: %-25s\n" "$DOMAIN"
printf " ${WHITE}ISP         ${NC}: %-25s\n" "$ISP"
printf " ${WHITE}OS          ${NC}: %-25s\n" "$OS"
printf " ${WHITE}UPTIME      ${NC}: %-25s\n" "$UPTIME"
printf " ${WHITE}CPU USAGE   ${NC}: %-25s\n" "$CPU"
printf " ${WHITE}RAM USAGE   ${NC}: %-25s\n" "$RAM"
printf " ${WHITE}DISK USAGE  ${NC}: %-25s\n" "$DISK"
printf " ${WHITE}SERVER TIME ${NC}: %-25s\n" "$TIME"

echo -e "${YELLOW}└─────────────────────────────────────────────┘${NC}"

# ================= BANDWIDTH =================

echo -e "${CYAN}┌──────────────── BANDWIDTH ──────────────────┐${NC}"

printf " ${WHITE}TODAY${NC}   : %-10s" "$TODAY"
printf " ${WHITE}YESTERDAY${NC}  : %-10s\n" "$YESTERDAY"

printf " ${WHITE}MONTH${NC}   : %-10s" "$MONTH"
printf " ${WHITE}TOTAL${NC}      : %-10s\n" "$TOTAL_BW"

echo -e "${CYAN}└─────────────────────────────────────────────┘${NC}"

# ================= USER ==================

echo -e "${CYAN}┌──────────────── USER STATS ─────────────────┐${NC}"

echo -e " ${WHITE}VMESS${NC} : $VMESS     ${WHITE}VLESS${NC} : $VLESS     ${WHITE}TROJAN${NC} : $TROJAN"

echo -e " ${WHITE}SSWS${NC}  : $SSWS     ${WHITE}SSH${NC}   : $SSH_USER"

echo -e " ${WHITE}TOTAL${NC} : $TOTAL    ${WHITE}ONLINE${NC} : $ONLINE"

echo -e "${CYAN}└─────────────────────────────────────────────┘${NC}"

# ================= SERVICE =================

echo -e "${BLUE}┌──────────────── SERVICE ────────────────────┐${NC}"

echo -e " ${WHITE}XRAY${NC}      : $XRAY  ${WHITE}NGINX${NC}     : $NGINX     "
echo -e " ${WHITE}DROPBEAR${NC}  : $DROPBEAR  ${WHITE}WIREGUARD${NC} : $WG        "
echo -e " ${WHITE}UDP CUSTOM${NC}: $UDPCUSTOM  ${WHITE}SSH WS${NC}    : $DROPBEARWS"
echo -e " ${WHITE}WSS${NC}       : $STUNNELWS"

echo -e "${BLUE}└─────────────────────────────────────────────┘${NC}"

# ================= MENU =================

echo -e "${RED}┌──────────────── MAIN MENU ──────────────────┐${NC}"

echo -e " [1] ${WHITE}SSH${NC}          [7] ${WHITE}TOOLS${NC}"
echo -e " [2] ${WHITE}VMESS${NC}        [8] ${WHITE}STATUS${NC}"
echo -e " [3] ${WHITE}VLESS${NC}        [9] ${WHITE}CLEAR RAM${NC}"
echo -e " [4] ${WHITE}TROJAN${NC}       [10] ${WHITE}REBOOT VPS${NC}"
echo -e " [5] ${WHITE}SSWS${NC}         [11] ${WHITE}UNINSTALL${NC}"
echo -e " [6] ${WHITE}WIREGUARD${NC}    [x] ${WHITE}EXIT${NC}"

echo -e "${RED}└─────────────────────────────────────────────┘${NC}"

echo -e "${RED}┌──────────────── LICENSE ────────────────────┐${NC}"
echo -e " ${WHITE}License${NC} : GEN-ULTIMATE-2026"
echo -e " ${WHITE}Type${NC}    : Lifetime Premium"
echo -e "${RED}└─────────────────────────────────────────────┘${NC}"

read -rp "Select Menu : " menu

case $menu in
1) m-ssh ;;
2) m-vmess ;;
3) m-vless ;;
4) m-trojan ;;
5) m-ssws ;;
6) m-wg ;;
7) tools-menu ;;
8) running ;;
9) sync; echo 3 > /proc/sys/vm/drop_caches; swapoff -a && swapon -a ;;
10) reboot ;;
11) bash /root/uninstall.sh ;;
x) exit ;;
*)
echo -e "${RED}❌ Invalid menu!${NC}"
sleep 1
exec "$0"
;;
esac
