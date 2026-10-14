#!/bin/bash
# Auto Delete Expired Trial Accounts - by GEN

# Current time
NOW=$(date +%s)

# Function to delete expired user from xray config
delete_user_from_config() {
    local username=$1
    local protocol=$2
    
    case $protocol in
        vmess)
            jq --arg user "$username" '
            (.inbounds[] | select(.tag=="vmess-ws-tls").settings.clients) |= map(select(.email != $user)) |
            (.inbounds[] | select(.tag=="vmess-ws-nontls").settings.clients) |= map(select(.email != $user))
            ' /etc/xray/config.json > /tmp/xray-temp.json && mv /tmp/xray-temp.json /etc/xray/config.json
            ;;
        vless)
            jq --arg user "$username" '
            (.inbounds[] | select(.tag=="vless-ws-tls").settings.clients) |= map(select(.email != $user)) |
            (.inbounds[] | select(.tag=="vless-ws-nontls").settings.clients) |= map(select(.email != $user))
            ' /etc/xray/config.json > /tmp/xray-temp.json && mv /tmp/xray-temp.json /etc/xray/config.json
            ;;
        trojan)
            jq --arg user "$username" '
            (.inbounds[] | select(.tag=="trojan-ws-tls").settings.clients) |= map(select(.email != $user))
            ' /etc/xray/config.json > /tmp/xray-temp.json && mv /tmp/xray-temp.json /etc/xray/config.json
            ;;
    esac
}

# Process VMess trials
if [[ -f /etc/xray/vmess-trial.db ]]; then
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        username=$(echo "$line" | awk '{print $1}')
        exp_time=$(echo "$line" | awk '{print $2" "$3}')
        exp_epoch=$(date -d "$exp_time" +%s 2>/dev/null)
        
        if [[ $NOW -ge $exp_epoch ]]; then
            echo "Deleting expired VMess trial: $username (expired at $exp_time)"
            delete_user_from_config "$username" "vmess"
            sed -i "/^${username} /d" /etc/xray/vmess-trial.db
        fi
    done < /etc/xray/vmess-trial.db
fi

# Process VLESS trials
if [[ -f /etc/xray/vless-trial.db ]]; then
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        username=$(echo "$line" | awk '{print $1}')
        exp_time=$(echo "$line" | awk '{print $2" "$3}')
        exp_epoch=$(date -d "$exp_time" +%s 2>/dev/null)
        
        if [[ $NOW -ge $exp_epoch ]]; then
            echo "Deleting expired VLESS trial: $username (expired at $exp_time)"
            delete_user_from_config "$username" "vless"
            sed -i "/^${username} /d" /etc/xray/vless-trial.db
        fi
    done < /etc/xray/vless-trial.db
fi

# Process Trojan trials
if [[ -f /etc/xray/trojan-trial.db ]]; then
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        username=$(echo "$line" | awk '{print $1}')
        exp_time=$(echo "$line" | awk '{print $2" "$3}')
        exp_epoch=$(date -d "$exp_time" +%s 2>/dev/null)
        
        if [[ $NOW -ge $exp_epoch ]]; then
            echo "Deleting expired Trojan trial: $username (expired at $exp_time)"
            delete_user_from_config "$username" "trojan"
            sed -i "/^${username} /d" /etc/xray/trojan-trial.db
        fi
    done < /etc/xray/trojan-trial.db
fi

# Restart xray if any changes made
if [[ -f /tmp/xray-temp.json ]] || grep -q "Deleting expired" /tmp/trial-cleanup.log 2>/dev/null; then
    systemctl restart xray
    echo "Xray restarted after cleaning expired trials"
fi
