# Changelog - Danautoscript

## Version 2.1.1 - Rebranding Edition (2026-10-14)

### 🎨 Branding Changes
- ✅ Changed project name from AutoscriptXRAY to **Danautoscript**
- ✅ Changed developer credit from ZNANDEV to **GEN**
- ✅ Updated license to **GEN-ULTIMATE-2026**
- ✅ Changed main panel title to **DANAUTOSCRIPT PANEL**

### 📂 Directory Changes
- ✅ Changed `/etc/autoscriptvpn/` to `/etc/danautoscript/`
- ✅ Updated all script paths to use new directory structure

### 🔧 Modified Files (24 files)

#### Core Files (3):
1. `setup.sh` - Main setup script
2. `menu.sh` - Main dashboard
3. `README.md` - Project documentation

#### Installation Scripts (5):
4. `install/nginx.sh` - NGINX installer
5. `install/xray.sh` - XRAY Core installer
6. `install/ssh.sh` - SSH WebSocket installer
7. `install/wg.sh` - WireGuard installer
8. `install/zivpn.sh` - UDP ZIVPN installer

#### Menu Scripts (8):
9. `ssh/m-ssh` - SSH menu
10. `xray/m-vmess` - VMess menu
11. `xray/m-vless` - VLESS menu
12. `xray/m-trojan` - Trojan menu
13. `xray/m-ssws` - Shadowsocks menu
14. `wg/m-wg` - WireGuard menu
15. `udp/m-zivpn` - UDP ZIVPN menu
16. `tools/tools-menu` - Tools menu

#### Documentation (2):
17. `BRANDING.md` - Branding information (NEW)
18. `CHANGELOG.md` - This file (NEW)

### 🔄 Path Updates
All script references updated:
```
OLD: /etc/autoscriptvpn/{ssh,xray,wg,udp,tools}/*
NEW: /etc/danautoscript/{ssh,xray,wg,udp,tools}/*
```

### 📝 Text Changes
- Panel loading text: "Loading ZNANDEV XRAY PANEL" → "Loading DANAUTOSCRIPT PANEL"
- Header text: "ZNANDEV XRAY PANEL" → "DANAUTOSCRIPT PANEL"
- License display: "ZNDEV-ULTIMATE-2026" → "GEN-ULTIMATE-2026"
- All file headers: "by znandev" → "by GEN"

### ⚙️ Features Maintained
All original features preserved:
- ✅ XRAY Core (VMess, VLESS, Trojan, Shadowsocks)
- ✅ SSH WebSocket + SSL
- ✅ WireGuard VPN
- ✅ UDP Custom + ZIVPN
- ✅ NGINX Reverse Proxy
- ✅ Auto SSL (acme.sh)
- ✅ User Management
- ✅ Traffic Monitoring
- ✅ Backup/Restore Tools

### 🎯 Installation
```bash
# Clone repository
git clone https://github.com/yourusername/danautoscript.git
cd danautoscript

# Run installer
chmod +x setup.sh
screen -S setup ./setup.sh
```

### 📌 Notes
- All functionality remains identical to original AutoscriptXRAY
- Only branding and naming conventions changed
- No breaking changes to configuration or database structure
- Compatible with existing VPS setups (fresh install recommended)

### 🙏 Credits
- Original project: AutoscriptXRAY by znandev
- Rebranded by: GEN
- Based on: XRAY Core, WireGuard, BadVPN, NGINX

---
**Danautoscript v2.1.1** - © 2026 GEN
