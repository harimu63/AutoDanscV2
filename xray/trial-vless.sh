#!/bin/bash
# Trial VLESS 60 Menit - by GEN

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m     Trial VLESS Account (60m)    \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# ambil domain
domain=$(cat /etc/xray/domain)

# public nginx port
tls="443"
none="80"

# Generate random username
user="trial-$(date +%s | tail -c 5)$(shuf -i 10-99 -n 1)"
uuid=$(cat /proc/sys/kernel/random/uuid)

# Set expiry 60 menit dari sekarang
exp_time=$(date -d "60 minutes" +"%Y-%m-%d %H:%M:%S")
exp=$(date -d "60 minutes" +"%Y-%m-%d")

echo ""
echo -e "Creating trial account..."

# backup config
cp /etc/xray/config.json /etc/xray/config.json.bak

# temp file
tmpfile=$(mktemp)

# inject user ke config
if ! jq --arg uuid "$uuid" --arg user "$user" '
(.inbounds[] | select(.tag=="vless-ws-tls").settings.clients) +=
[{"id":$uuid,"email":$user}] |

(.inbounds[] | select(.tag=="vless-ws-nontls").settings.clients) +=
[{"id":$uuid,"email":$user}]
' /etc/xray/config.json > "$tmpfile"; then

    echo ""
    echo "ERROR: Failed inject config!"
    rm -f "$tmpfile"
    exit 1

fi

# replace config
mv "$tmpfile" /etc/xray/config.json

# restart xray
systemctl restart xray

# cek status xray
if ! systemctl is-active --quiet xray; then
    echo ""
    echo "ERROR: Xray failed start!"
    cp /etc/xray/config.json.bak /etc/xray/config.json
    systemctl restart xray
    exit 1
fi

# simpan database user dengan expire time
echo "${user} ${exp_time} ${uuid}" >> /etc/xray/vless-trial.db

# generate vless link
vlesslink1="vless://${uuid}@${domain}:${tls}?path=/vless&security=tls&encryption=none&host=${domain}&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:${none}?path=/vless&security=none&encryption=none&host=${domain}&type=ws#${user}"

clear

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m     TRIAL VLESS ACCOUNT (60m)    \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${none}"
echo -e "UUID           : ${uuid}"
echo -e "Encryption     : none"
echo -e "Network        : ws"
echo -e "Path           : /vless"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       :"
echo -e "${vlesslink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  :"
echo -e "${vlesslink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : ${exp_time}"
echo -e "⏰ TRIAL: Auto deleted in 60 minutes!"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

echo ""
echo "Trial account will be automatically deleted at: ${exp_time}"
echo ""

read -n 1 -s -r -p "Press any key to back to menu..."

m-vless
