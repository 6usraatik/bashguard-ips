#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/opt/bashguard-ips"
SERVICE_FILE="/etc/systemd/system/bashguard.service"

echo "=== BashGuard-IPS Sistemden Kaldırılıyor ==="

if [[ $EUID -ne 0 ]]; then
   echo "[HATA] Bu script root yetkileriyle (sudo) çalıştırılmalıdır!" >&2
   exit 1
fi

echo "[-] Servis durduruluyor ve devre dışı bırakılıyor..."
systemctl stop bashguard.service 2>/dev/null || true
systemctl disable bashguard.service 2>/dev/null || true

echo "[-] Servis dosyaları siliniyor..."
rm -f "$SERVICE_FILE"
systemctl daemon-reload

echo "[-] Kurulum dizini ($INSTALL_DIR) siliniyor..."
rm -rf "$INSTALL_DIR"

# Opsiyonel: Kalan iptables zincirini temizle
iptables -D INPUT -j BASHGUARD_IPS 2>/dev/null || true
iptables -F BASHGUARD_IPS 2>/dev/null || true
iptables -X BASHGUARD_IPS 2>/dev/null || true

echo -e "\033[1;32m[BAŞARILI] BashGuard-IPS sistemden tamamen kaldırıldı.\033[0m"
