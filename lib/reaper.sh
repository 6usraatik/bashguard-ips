#!/usr/bin/env bash

set -euo pipefail

# Süresi dolan IP'leri kontrol eden ve engeli kaldıran ana fonksiyon
check_and_unban_expired() {
    local db_file="$1"
    
    # Eğer veritabanı dosyası yoksa veya boşsa işlem yapma
    if [[ ! -f "$db_file" || ! -s "$db_file" ]]; then
        return 0
    fi

    local current_time
    current_time=$(date +%s)
    
    # Geçici bir dosya oluşturarak sadece engeli devam edenleri burada tutacağız
    local temp_db
    temp_db=$(mktemp)

    # Veritabanını satır satır oku (Format: ban_end|ip|timestamp)
    # IFS='|' satırı dikey çizgiye göre parçalar
    while IFS='|' read -r ban_end ip timestamp; do
        if (( current_time >= ban_end )); then
            # Süre dolmuş! İnfaz motorundaki unban fonksiyonunu çağır
            unban_ip "$ip"
        else
            # Süre henüz dolmamış, bu kaydı geçici veritabanına geri yaz
            echo "$ban_end|$ip|$timestamp" >> "$temp_db"
        fi
    done < "$db_file"

    # Orijinal veritabanını güncel tutmak için geçici dosyayı üzerine yaz
    mv "$temp_db" "$db_file"
}

# Arka planda sürekli çalışacak döngü
start_reaper() {
    local db_file="$1"
    local interval="${2:-5}" # Varsayılan olarak her 5 saniyede bir kontrol et

    echo "=== Af Motoru (Reaper) Arka Planda Başlatıldı ==="
    echo "[-] Kontrol Periyodu: $interval saniye"
    echo "--------------------------------------------"

    # Sonsuz döngü: Her X saniyede bir expired (süresi dolmuş) ban'ları denetler
    while true; do
        check_and_unban_expired "$db_file"
        sleep "$interval"
    done
}
