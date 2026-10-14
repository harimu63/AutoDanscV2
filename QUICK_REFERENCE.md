# 🎯 DANAUTOSCRIPT - Quick Reference

## 📦 Installation Command (Copy-Paste Ready)

```bash
apt update -y && apt upgrade -y && apt install git curl screen -y && sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -w net.ipv6.conf.default.disable_ipv6=1 && cd /root && git clone https://github.com/harimu63/AutoDanscV2.git && cd AutoDanscV2 && chmod +x setup.sh && screen -S setup ./setup.sh
```

## 🔑 Main Commands

| Command | Description |
|---------|-------------|
| `menu` | Open main dashboard |
| `m-ssh` | SSH management menu |
| `m-vmess` | VMess management |
| `m-vless` | VLESS management |
| `m-trojan` | Trojan management |
| `m-ssws` | Shadowsocks management |
| `m-wg` | WireGuard management |
| `m-zivpn` | UDP ZIVPN management |
| `tools-menu` | Tools & utilities |

## 🔄 Update Command

```bash
bash /etc/danautoscript/tools/update.sh
```

## 📂 Important Paths

| Path | Description |
|------|-------------|
| `/etc/danautoscript/` | Main scripts directory |
| `/etc/xray/` | XRAY configuration |
| `/etc/nginx/conf.d/xray.conf` | NGINX config |
| `/root/AutoDanscV2/` | Installation source |

## 🔌 Default Ports

| Service | Port |
|---------|------|
| SSH | 22 |
| Dropbear | 109, 143 |
| SSH WS | 2082 |
| SSH SSL WS | 2096 |
| XRAY TLS | 443 |
| XRAY Non-TLS | 80 |
| BadVPN UDPGW | 7300 |

## 🛠️ Troubleshooting

### Service not running?
```bash
systemctl restart nginx
systemctl restart xray
systemctl restart dropbear
systemctl restart dropbear-ws
systemctl restart stunnel-ws
```

### Check service status:
```bash
systemctl status nginx
systemctl status xray
ss -tulpn | grep -E '443|80|22|109|143|2082|2096'
```

### View logs:
```bash
journalctl -u xray -n 50
journalctl -u nginx -n 50
tail -f /var/log/xray/access.log
```

## 🔄 Update Workflow

1. **Developer pushes update to GitHub**
2. **User runs:** `menu → Tools → Update`
3. **Auto backup created**
4. **Download latest from GitHub**
5. **Update all files**
6. **Done!**

## 📞 Quick Info

- **Developer:** GEN
- **Repository:** harimu63/AutoDanscV2
- **Version:** v2.1.1-GEN
- **License:** GEN-ULTIMATE-2026

---

**Need help? Check full documentation in INSTALL_GUIDE.md**
