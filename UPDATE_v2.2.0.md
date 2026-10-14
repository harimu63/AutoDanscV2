# ✅ UPDATE v2.2.0 - Danautoscript

## 🎉 New Features & Fixes

### **1. Fixed Bandwidth Usage Display** ✅
- ✅ Fixed vnstat initialization
- ✅ Auto-create vnstat database if not exists
- ✅ Better error handling for network interface detection
- ✅ Display will now show actual bandwidth usage

### **2. Removed ZIVPN Feature** ✅
- ✅ Removed ZIVPN from menu
- ✅ Removed ZIVPN from service status
- ✅ Removed ZIVPN user count
- ✅ Cleaned up all ZIVPN references

### **3. Trial Account Feature (60 Minutes)** ✨ NEW!
- ✅ **VMess Trial** - Auto-generated username, 60 min expiry
- ✅ **VLESS Trial** - Auto-generated username, 60 min expiry
- ✅ **Trojan Trial** - Auto-generated username, 60 min expiry
- ✅ **Auto-Delete** - Expired trials deleted automatically via cron
- ✅ Random username format: `trial-xxxxx`

---

## 📋 Trial Feature Details

### How It Works:

1. **User Access Menu**
   ```
   menu → [2] VMESS → [2] Trial VMess (60 menit)
   ```

2. **Auto Generation**
   - Random username: `trial-12345`
   - Random UUID generated
   - Expiry: Current time + 60 minutes

3. **Auto Deletion**
   - Cron job runs every minute
   - Checks all trial accounts
   - Deletes expired ones
   - Auto restart xray

### Trial Databases:
- `/etc/xray/vmess-trial.db`
- `/etc/xray/vless-trial.db`
- `/etc/xray/trojan-trial.db`

Format: `username expiry_datetime uuid`

Example:
```
trial-12345 2026-10-14 15:30:00 abc123-uuid-here
```

---

## 📂 New Files Created

### Trial Scripts:
1. `xray/trial-vmess.sh` - VMess trial generator
2. `xray/trial-vless.sh` - VLESS trial generator
3. `xray/trial-trojan.sh` - Trojan trial generator
4. `xray/cleanup-trial.sh` - Auto delete expired trials

### Modified Files:
1. `menu.sh` - Removed ZIVPN, fixed bandwidth
2. `xray/m-vmess` - Added trial option
3. `xray/m-vless` - Added trial option
4. `xray/m-trojan` - Added trial option
5. `setup.sh` - Added cron job setup

---

## 🎯 Menu Structure Update

### Main Menu:
```
[1] SSH          [7] TOOLS
[2] VMESS        [8] STATUS
[3] VLESS        [9] CLEAR RAM
[4] TROJAN       [10] REBOOT VPS
[5] SSWS         [11] UNINSTALL
[6] WIREGUARD    [x] EXIT
```

### VMess Menu:
```
[1] Tambah Akun VMess
[2] Trial VMess (60 menit) ⏰  ← NEW!
[3] Hapus Akun VMess
[4] Cek Login VMess
[5] Perpanjang Masa Aktif Akun
[x] Kembali ke menu utama
```

### VLESS Menu:
```
[1] Tambah Akun VLESS
[2] Trial VLESS (60 menit) ⏰  ← NEW!
[3] Hapus Akun VLESS
[4] Cek Login VLESS
[5] Perpanjang Masa Aktif Akun
[x] Kembali ke menu utama
```

### Trojan Menu:
```
[1] Tambah Akun Trojan
[2] Trial Trojan (60 menit) ⏰  ← NEW!
[3] Hapus Akun Trojan
[4] Cek Login Trojan
[5] Perpanjang Masa Aktif Akun
[x] Kembali ke menu utama
```

---

## 🔧 Bandwidth Fix Details

### Before (Broken):
```
┌──────────────── BANDWIDTH ──────────────────┐
 TODAY   :            YESTERDAY  : 0 B       
 MONTH   :            TOTAL      : 0 B       
└─────────────────────────────────────────────┘
```

### After (Working):
```
┌──────────────── BANDWIDTH ──────────────────┐
 TODAY   : 245 MiB     YESTERDAY  : 1.2 GiB  
 MONTH   : 15.3 GiB    TOTAL      : 45.8 GiB 
└─────────────────────────────────────────────┘
```

### Fix Applied:
- Auto-detect network interface
- Create vnstat database if not exists
- Better error handling
- Proper month name format

---

## 🤖 Cron Job Setup

Auto-delete trial accounts:
```bash
# Runs every minute
* * * * * /etc/danautoscript/xray/cleanup-trial.sh >> /var/log/trial-cleanup.log 2>&1
```

Check cron:
```bash
crontab -l
```

View cleanup log:
```bash
tail -f /var/log/trial-cleanup.log
```

---

## 🚀 Installation

### Fresh Install:
```bash
cd /root
git clone https://github.com/harimu63/AutoDanscV2.git
cd AutoDanscV2
chmod +x setup.sh
bash setup.sh
```

### Update Existing:
```bash
cd /root/AutoDanscV2
git pull origin main
bash setup.sh
```

---

## 🧪 Testing

### Test Trial Feature:
1. Login to menu: `menu`
2. Select VMess: `2`
3. Select Trial: `2`
4. Account created instantly
5. Wait 60 minutes
6. Account auto-deleted

### Test Bandwidth:
1. Login to menu: `menu`
2. Check bandwidth section
3. Should show actual usage

### Manual Test Cleanup:
```bash
bash /etc/danautoscript/xray/cleanup-trial.sh
```

---

## 📝 Version Info

**Version:** v2.2.0-GEN
**Date:** 2026-10-14
**Changes:**
- Fixed bandwidth display
- Removed ZIVPN feature
- Added trial accounts (60 min)
- Auto-delete expired trials

---

## ✅ Summary

| Feature | Status |
|---------|--------|
| Bandwidth display | ✅ Fixed |
| ZIVPN removal | ✅ Removed |
| VMess trial | ✅ Added |
| VLESS trial | ✅ Added |
| Trojan trial | ✅ Added |
| Auto-delete trial | ✅ Added |
| Cron job | ✅ Setup |

---

**Ready to deploy!** 🚀

Push to GitHub and update your VPS.

---

© 2026 GEN - Danautoscript v2.2.0
