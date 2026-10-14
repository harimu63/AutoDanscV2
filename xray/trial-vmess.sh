#!/bin/bash
# Trial VMess 60 Menit - by GEN

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m     Trial VMess Account (60m)    \E[0m"
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
(.inbounds[] | select(.tag=="vmess-ws-tls").settings.clients) +=
[{"id":$uuid,"alterId":0,"email":$user}] |

(.inbounds[] | select(.tag=="vmess-ws-nontls").settings.clients) +=
[{"id":$uuid,"alterId":0,"email":$user}]
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
echo "${user} ${exp_time} ${uuid}" >> /etc/xray/vmess-trial.db

# generate vmess tls
vmess_json_tls=$(cat <<EOF
{
  "v":"2",
  "ps":"${user}",
  "add":"${domain}",
  "port":"${tls}",
  "id":"${uuid}",
  "aid":"0",
  "net":"ws",
  "type":"none",
  "host":"${domain}",
  "path":"/vmess",
  "tls":"tls",
  "sni":"${domain}"
}
EOF
)

# generate vmess nontls
vmess_json_none=$(cat <<EOF
{
  "v":"2",
  "ps":"${user}",
  "add":"${domain}",
  "port":"${none}",
  "id":"${uuid}",
  "aid":"0",
  "net":"ws",
  "type":"none",
  "host":"${domain}",
  "path":"/vmess",
  "tls":"none"
}
EOF
)

# encode vmess
vmesslink1="vmess://$(echo "$vmess_json_tls" | base64 -w 0)"
vmesslink2="vmess://$(echo "$vmess_json_none" | base64 -w 0)"

clear

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m     TRIAL VMESS ACCOUNT (60m)    \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "Port TLS       : ${tls}"
echo -e "Port none TLS  : ${none}"
echo -e "UUID           : ${uuid}"
echo -e "Alter ID       : 0"
echo -e "Network        : ws"
echo -e "Path           : /vmess"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link TLS       :"
echo -e "${vmesslink1}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Link none TLS  :"
echo -e "${vmesslink2}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "Expired On     : ${exp_time}"
echo -e "⏰ TRIAL: Auto deleted in 60 minutes!"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

echo ""
echo "Trial account will be automatically deleted at: ${exp_time}"
echo ""

read -n 1 -s -r -p "Press any key to back to menu..."

m-vmess
