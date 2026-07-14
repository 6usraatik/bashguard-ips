#!/usr/bin/env bash

set -euo pipefail

# Kütüphaneleri yükle
source lib/utils.sh
source lib/firewall.sh
source lib/state.sh
source lib/reaper.sh    # YENİ: Af motorunu dâhil ettik

# 1. Konfigürasyonu yükle
load_config "conf/bashguard.conf"

# 2. Firewall altyapısını başlat/kontrol et
init_firewall

# 3. YENİ: Af Motorunu arka planda başlat (Süreci yönetmek için PID'sini alacağız)
# Burada & işareti fonksiyonun arka planda (subshell) çalışmasını sağlar
start_reaper "$DB_FILE" 5 &
REAPER_PID=$! # Son başlatılan arka plan işleminin Process ID'sini (PID) al

# YENİ: Kullanıcı CTRL+C yaptığında çalışacak temizlik fonksiyonu
cleanup() {
    echo -e "\n[KAPANIŞ] BashGuard-IPS kapatılıyor..."
    echo "[-] Arka plan süreçleri sonlandırılıyor (PID: $REAPER_PID)..."
    kill "$REAPER_PID" 2>/dev/null || true
    echo "[!] Güvenli şekilde çıkış yapıldı. İyi günler!"
    exit 0
}

# TRAP tanımı: SIGINT (CTRL+C) ve SIGTERM (kapatma) sinyalleri geldiğinde cleanup fonksiyonunu çalıştır
trap cleanup SIGINT SIGTERM

# 4. Gerçek zamanlı izleme motorunu başlat (Ön planda çalışır)
monitor_realtime "$LOG_FILE" "$MAX_ATTEMPTS"
