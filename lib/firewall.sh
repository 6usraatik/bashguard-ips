#!/usr/bin/env bash

set -euo pipefail


CHAIN_NAME="BASHGUARD_IPS"

# Komut çalıştırıcı yardımcı fonksiyon (DRY_RUN kontrolü yapar)
run_cmd() {
    if [[ "${DRY_RUN:-true}" == "true" ]]; then
        echo -e "\033[1;33m[DRY-RUN SİMÜLASYONU] Çalıştırılacak Komut:\033[0m $*"
    else
        # Gerçek modda çalışıyorsa komutu sudo yetkisiyle uygula
        sudo "$@"
    fi
}

# Özel zincir oluştur ve sistemin ana girişine (INPUT) bağla
init_firewall() {
    echo "[-] Firewall altyapısı kontrol ediliyor..."
    
    if [[ "${DRY_RUN:-true}" == "true" ]]; then
        echo "[BİLGİ] DRY-RUN aktif. Firewall kuralları gerçekten eklenmeyecek, sadece simüle edilecek."
        return 0
    fi

    # BASHGUARD_IPS zinciri var mı diye kontrol et, yoksa oluştur
    if ! sudo iptables -L "$CHAIN_NAME" -n >/dev/null 2>&1; then
        echo "[FIREWALL] '$CHAIN_NAME' zinciri oluşturuluyor..."
        sudo iptables -N "$CHAIN_NAME"
        # INPUT trafiğini bizim zincirimize yönlendir
        sudo iptables -I INPUT -j "$CHAIN_NAME"
    fi
}

# IP Engelleme Fonksiyonu
ban_ip() {
    local ip="$1"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local ban_end=$(($(date +%s) + BAN_TIME))

    echo -e "\033[1;31m[İNFAZ - BAN] IP Engelleniyor:\033[0m $ip (Süre: $BAN_TIME saniye)"
    
    # iptables kuralını ekle (Gelen trafiği DROP et - yani görmezden gel)
    run_cmd iptables -I "$CHAIN_NAME" -s "$ip" -j DROP

    # af motoru daha sonra ban'ı kaldırabilsin diye veritabanı dosyasına kaydet
    # Format: Bitiş_Zamanı|IP_Adresi|Bağlantı_Zamanı
    echo "$ban_end|$ip|$timestamp" >> "$DB_FILE"
}

# Af Fonksiyonu
unban_ip() {
    local ip="$1"
    echo -e "\033[1;32m[İNFAZ - AF] IP Engeli Kaldırılıyor:\033[0m $ip"
    
    # iptables kuralını sil (-D: Delete)
    run_cmd iptables -D "$CHAIN_NAME" -s "$ip" -j DROP
}
