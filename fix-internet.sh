#!/bin/bash
# Quick Fix DNS & Internet - Danautoscript

echo "Fixing DNS & Internet Connection..."
echo ""

# Backup old resolv.conf
cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null

# Remove immutable flag if exists
chattr -i /etc/resolv.conf 2>/dev/null

# Set Google & Cloudflare DNS
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

echo "✓ DNS updated"

# Test connection
echo ""
echo "Testing connection..."
echo ""

if ping -c 2 8.8.8.8 &>/dev/null; then
    echo "✓ Ping to 8.8.8.8 OK"
else
    echo "✗ Cannot ping 8.8.8.8"
fi

if ping -c 2 google.com &>/dev/null; then
    echo "✓ DNS resolution OK"
else
    echo "✗ DNS resolution failed"
fi

if ping -c 2 github.com &>/dev/null; then
    echo "✓ Can reach GitHub"
else
    echo "✗ Cannot reach GitHub"
fi

echo ""
echo "Done! Try update again."
