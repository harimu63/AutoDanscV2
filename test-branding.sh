#!/bin/bash
# Quick Test Script - Danautoscript
# Run this after installation to verify branding

echo "======================================"
echo "  DANAUTOSCRIPT - Branding Test"
echo "======================================"
echo ""

# Test 1: Check directory
echo "[1] Checking directory structure..."
if [ -d "/etc/danautoscript" ]; then
    echo "    ✅ /etc/danautoscript exists"
else
    echo "    ❌ /etc/danautoscript NOT FOUND"
fi

# Test 2: Check menu command
echo ""
echo "[2] Checking menu command..."
if [ -f "/usr/bin/menu" ]; then
    echo "    ✅ menu command exists"
else
    echo "    ❌ menu command NOT FOUND"
fi

# Test 3: Check submenu commands
echo ""
echo "[3] Checking submenu commands..."
commands=("m-ssh" "m-vmess" "m-vless" "m-trojan" "m-ssws" "m-wg" "m-zivpn" "tools-menu")
for cmd in "${commands[@]}"; do
    if [ -f "/usr/bin/$cmd" ]; then
        echo "    ✅ $cmd exists"
    else
        echo "    ❌ $cmd NOT FOUND"
    fi
done

# Test 4: Check branding in menu.sh
echo ""
echo "[4] Checking branding in menu.sh..."
if grep -q "DANAUTOSCRIPT PANEL" /usr/bin/menu 2>/dev/null; then
    echo "    ✅ DANAUTOSCRIPT branding found"
else
    echo "    ❌ DANAUTOSCRIPT branding NOT FOUND"
fi

if grep -q "GEN-ULTIMATE-2026" /usr/bin/menu 2>/dev/null; then
    echo "    ✅ GEN license found"
else
    echo "    ❌ GEN license NOT FOUND"
fi

# Test 5: Check services
echo ""
echo "[5] Checking services..."
services=("nginx" "xray" "dropbear" "dropbear-ws" "stunnel-ws")
for svc in "${services[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo "    ✅ $svc is running"
    else
        echo "    ⚠️  $svc is not running"
    fi
done

echo ""
echo "======================================"
echo "  Test Complete!"
echo "======================================"
