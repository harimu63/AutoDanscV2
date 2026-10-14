# 🔄 Auto Update Feature - Danautoscript

## ✨ Fitur Baru: Auto Update dari GitHub

Danautoscript sekarang memiliki fitur **Auto Update** yang akan mengambil versi terbaru langsung dari GitHub repository Anda.

---

## 📋 Cara Menggunakan

### Method 1: Via Menu Tools (Recommended)
```bash
# Buka menu utama
menu

# Pilih [8] TOOLS
# Pilih [5] Update Danautoscript
```

### Method 2: Via Command Direct
```bash
bash /etc/danautoscript/tools/update.sh
```

---

## 🔧 Apa yang Dilakukan Script Update?

### Proses Update (6 Langkah):

1. **Check Internet** ✅
   - Memastikan koneksi internet tersedia

2. **Check Git** ✅
   - Memastikan git terinstall
   - Auto-install jika belum ada

3. **Backup Current** 💾
   - Backup instalasi saat ini ke `/root/danautoscript-backup-TIMESTAMP`
   - Safety measure jika update gagal

4. **Fetch Updates** 📥
   - Download versi terbaru dari GitHub
   - Source: `https://github.com/harimu63/danautoscript.git`

5. **Update Files** 🔄
   - Update semua menu commands
   - Update semua scripts di `/etc/danautoscript/`
   - Set permissions otomatis

6. **Version Check** ✔️
   - Tampilkan versi yang ter-update

---

## 📂 File Structure

```
tools/
├── backup.sh          # Backup & restore
├── speedtest.sh       # Speedtest VPS
├── domain.sh          # Ganti domain
├── running.sh         # Check services
└── update.sh          # 🆕 Auto update (NEW!)
```

---

## ⚙️ Konfigurasi

Update script menggunakan config:
```bash
GITHUB_USER="harimu63"
GITHUB_REPO="AutoDanscV2"
GITHUB_BRANCH="main"
GITHUB_URL="https://github.com/harimu63/AutoDanscV2.git"
```

Jika ingin ganti repository, edit file `/etc/danautoscript/tools/update.sh`

---

## 🛡️ Safety Features

### 1. Auto Backup
- Setiap update otomatis backup instalasi lama
- Lokasi: `/root/danautoscript-backup-YYYYMMDD-HHMMSS`

### 2. Rollback on Fail
- Jika download gagal → auto restore backup
- Jika update error → instalasi lama tetap aman

### 3. Optional Cleanup
- Setelah update sukses, bisa hapus backup (opsional)
- Atau simpan backup untuk jaga-jaga

---

## 📝 Version Tracking

File `version.txt` di root repository untuk tracking versi:
```
v2.1.1-GEN
```

Update versi ini setiap kali ada perubahan besar.

---

## 🚀 Workflow Update

```
Developer (You)
    ↓
Push update ke GitHub (harimu63/AutoDanscV2)
    ↓
User di VPS
    ↓
Jalankan menu → Tools → Update
    ↓
Auto download & install
    ↓
Done! ✅
```

---

## 💡 Best Practices

### Untuk Developer (Anda):
1. **Commit & Push** setiap update ke GitHub
2. **Update version.txt** jika ada perubahan major
3. **Test di VPS testing** sebelum release ke production

### Untuk User:
1. **Backup manual** sebelum update (opsional, ada auto backup)
2. **Check changelog** untuk tahu apa yang berubah
3. **Update saat low traffic** untuk avoid downtime

---

## 🔍 Troubleshooting

### Update Gagal?
```bash
# Check internet
ping google.com

# Check git
git --version

# Manual update
cd /root
rm -rf AutoDanscV2
git clone https://github.com/harimu63/AutoDanscV2.git
cd AutoDanscV2
bash setup.sh
```

### Restore Backup?
```bash
# List backups
ls -la /root/danautoscript-backup-*

# Restore backup tertentu
cd /root
rm -rf AutoDanscV2
cp -r danautoscript-backup-TIMESTAMP AutoDanscV2
```

---

## 📊 Update Log Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🔄 DANAUTOSCRIPT AUTO UPDATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/6] Checking internet connection...
✔ Internet connected

[2/6] Checking git installation...
✔ Git ready

[3/6] Backing up current installation...
✔ Backup saved to: /root/danautoscript-backup-20261014-120530

[4/6] Fetching updates from GitHub...
✔ Successfully downloaded latest version

[5/6] Updating system files...
→ Updating menu files...
→ Updating script files...
✔ Files updated successfully

[6/6] Checking version...
✔ Updated to version: v2.1.1-GEN

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ✅ UPDATE COMPLETED!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Update Summary:
 • Source: github.com/harimu63/AutoDanscV2
 • Install Dir: /root/danautoscript
 • Backup: /root/danautoscript-backup-20261014-120530

Run 'menu' to see changes
```

---

## ✅ Summary

| Feature | Status |
|---------|--------|
| Auto download from GitHub | ✅ |
| Auto backup before update | ✅ |
| Rollback on failure | ✅ |
| Version tracking | ✅ |
| Menu integration | ✅ |
| Easy to use | ✅ |

---

**Fitur Auto Update siap digunakan!** 🎉

Setiap kali Anda push update ke GitHub, user tinggal pilih menu Tools → Update Danautoscript dan otomatis ter-update!

---

© 2026 GEN - Danautoscript
