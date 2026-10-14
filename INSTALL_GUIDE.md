# 🎉 DANAUTOSCRIPT - Installation Guide

<div align="center">

![Version](https://img.shields.io/badge/version-2.1.1-blue.svg)
![License](https://img.shields.io/badge/license-GEN--ULTIMATE--2026-green.svg)
![Status](https://img.shields.io/badge/status-stable-success.svg)

**Danautoscript** - Multi-Protocol VPN Auto Installer
Powered by GEN

</div>

---

## 📋 Features

| Category    | Features                                                                          |
| ----------- | --------------------------------------------------------------------------------- |
| SSH WS      | OpenSSH, Dropbear, SSH WS, SSH SSL WS, Enhanced Payload, UDP Custom, BadVPN UDPGW |
| XRAY Core   | VMess, VLESS, Trojan, Shadowsocks, gRPC, NGINX Reverse Proxy, Auto SSL            |
| WireGuard   | WireGuard VPN, Client Generator, QR Code                                          |
| UDP Tunnel  | UDP Custom, ZIVPN UDP, BadVPN UDPGW                                               |
| Management  | Backup, Domain Manager, Speedtest, Service Checker, Traffic Monitor               |
| Dashboard   | Interactive Panel, Service Status, User Statistics, Traffic Statistics            |
| Go Services | Native Dropbear WS, Native Stunnel WS, Multi-Connection Support                   |

---

## 🚀 Quick Install

> **Note:** This script must be run as root!

```bash
# Update system
apt update -y && apt upgrade -y
apt install git curl screen sudo -y

# Disable IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Clone repository
git clone https://github.com/harimu63/AutoDanscV2.git
cd AutoDanscV2

# Run installer
chmod +x setup.sh
chmod +x uninstall.sh
screen -S setup ./setup.sh
```

---

## 🎯 Access Dashboard

After installation, open the main menu with:

```bash
menu
```

---

## 🔌 Default Ports

| Service        | Port    |
| -------------- | ------- |
| OpenSSH        | 22      |
| Dropbear       | 109,143 |
| SSH WS         | 2082    |
| SSH SSL WS     | 2096    |
| BadVPN UDPGW   | 7300    |
| UDP Custom     | 1-65535 |
| VMess TLS      | 443     |
| VMess None TLS | 80      |
| VLESS TLS      | 443     |
| Trojan TLS     | 443     |
| Shadowsocks WS | 443     |

---

## 🛠️ Debugging Commands

### Check Listening Ports:
```bash
ss -tulpn
```

### Check NGINX:
```bash
nginx -t
systemctl status nginx
```

### Check XRAY:
```bash
xray -test -config /etc/xray/config.json
systemctl status xray
```

### Check SSH WS:
```bash
systemctl status dropbear-ws
systemctl status stunnel-ws
```

### Check UDP Tunnel:
```bash
systemctl status udp-custom
systemctl status udpgw
```

---

## 💻 System Compatibility

| OS           | Status        |
| ------------ | ------------- |
| Debian 12    | ⭐ Recommended |
| Debian 11    | ✅ Supported   |
| Ubuntu 22.04 | ✅ Supported   |
| Ubuntu 20.04 | ⚠️ Limited     |
| Debian 10    | ❌ Deprecated  |
| OpenVZ       | ❌ Unsupported |
| KVM          | ✅ Recommended |
| VMware       | ✅ Recommended |

---

## 📁 Directory Structure

```
/etc/danautoscript/
├── ssh/          # SSH management scripts
├── xray/         # XRAY protocol scripts
├── wg/           # WireGuard scripts
├── udp/          # UDP tunnel scripts
└── tools/        # Utility tools
```

---

## ⚠️ Important Notes

* ✅ Recommended fresh VPS installation
* ✅ Recommended minimum RAM 1GB
* ✅ Domain required for XRAY TLS
* ✅ Cloudflare supported
* ✅ Enhanced payload supported

---

## 🗑️ Uninstall

To completely remove Danautoscript:

```bash
cd AutoDanscV2
bash uninstall.sh
```

---

## 🔄 Update

```bash
cd AutoDanscV2
git pull
bash setup.sh
```

---

## 📝 License

**GEN-ULTIMATE-2026**
Type: Lifetime Premium

---

## ❤️ Credits

* **GEN** - Danautoscript Developer
* **XTLS / Xray-core** - Core protocol
* **BadVPN** - UDP tunnel
* **WireGuard** - VPN protocol
* **acme.sh** - SSL certificate
* **NGINX** - Reverse proxy

---

## 📞 Support

For issues and support:
- Create an issue on GitHub
- Contact developer: GEN

---

## 🌟 Star This Repository

If you find this project useful, please give it a star! ⭐

---

<div align="center">

**© 2026 GEN - Danautoscript**

Made with ❤️ for the VPN community

</div>
