#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/opt/bashguard-ips"
SERVICE_FILE="/etc/systemd/system/bashguard.service"

echo "=== BashGuard-IPS Kurulumu Başlatılıyor ==="

# 1. Root yetkisi kontrolü
if [[ $EUID -ne 0 ]]; then
   echo "[HATA] Bu kurulum scripti root yetkileriyle (sudo) çalıştırılmalıdır!" >&2
   exit 1
fi

# 2. Kurulum dizinini oluştur ve dosyaları kopyala
echo "[-] Dosyalar $INSTALL_DIR dizinine kopyalanıyor..."
mkdir -p "$INSTALL_DIR"
cp -r conf lib data tests bashguard.sh "$INSTALL_DIR/"

# 3. Çalıştırma izinlerini ver
chmod +x "$INSTALL_DIR/bashguard.sh"
chmod -R 755 "$INSTALL_DIR/lib"

# 4. Systemd servis dosyasını sistemin merkezine kopyala
echo "[-] Systemd servisi entegre ediliyor..."
cp bashguard.service "$SERVICE_FILE"
chmod 644 "$SERVICE_FILE"

# 5. Systemd daemon'ını yenile ve servisi başlat
systemctl daemon-reload
systemctl enable bashguard.service
systemctl restart bashguard.service

echo -e "\033[1;32m[BAŞARILI] BashGuard-IPS sistem servisi olarak kuruldu ve başlatıldı!\033[0m"
echo "------------------------------------------------------------------"
echo " -> Servis Durumu : sudo systemctl status bashguard"
echo " -> Canlı Loglar  : sudo journalctl -u bashguard -f"
echo " -> Durdurmak için: sudo systemctl stop bashguard"
echo "------------------------------------------------------------------"
