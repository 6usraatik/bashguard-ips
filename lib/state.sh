#!/usr/bin/env bash

set -euo pipefail

# Bash'te Associative Array (Sözlük/Harita yapısı) tanımı. 
# Bu sayede hafızada ATTACKERS["203.0.113.45"]=4 şeklinde veri tutabiliriz.
declare -A ATTACKERS

monitor_realtime() {
    local log_file="$1"
    local max_attempts="$2"

    echo "=== Gerçek Zamanlı IPS Motoru Başlatıldı ==="
    echo "[-] İzlenen Log: $log_file"
    echo "[-] Alarm Eşiği : $max_attempts başarısız deneme"
    echo "[-] Çıkış için CTRL+C tuşlarına basabilirsiniz..."
    echo "--------------------------------------------"

    # tail -F: Dosya silinip yeniden oluşturulsa (log rotation) dahi takibi bırakmaz.
    # < <(...) kullanımı (Process Substitution): tail komutunu ayrı bir alt kabukta
    # çalıştırmaktan kurtarır, böylece ATTACKERS dizisindeki veriler döngü bitince kaybolmaz!
    
    while read -r line; do
        # Gelen canlı log satırında "Failed password" ifadesi var mı?
        if [[ "$line" =~ "Failed password" ]]; then
            
            # Satırdan IP adresini regex ile cımbızla (Yoksa hata vermemesi için || true ekledik)
            local ip
            ip=$(echo "$line" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" || true)

            if [[ -n "$ip" ]]; then
                # Hafızadaki sayaç değerini 1 artır (Eğer IP ilk kez geliyorsa 0 kabul et)
                ATTACKERS["$ip"]=$((${ATTACKERS["$ip"]:-0} + 1))
                local count=${ATTACKERS["$ip"]}

                echo "[GÖZLEM] IP: $ip | Anlık Deneme: $count/$max_attempts"

                # Eşik değeri tam olarak aşıldı mı?
                if (( count == max_attempts )); then
                    echo "[ALARM] !!! EŞİK DEĞERİ AŞILDI !!! -> IP: $ip"
                    # İŞTE BURASI: Saldırganı doğrudan firewall infaz fonksiyonumuza gönderiyoruz!
                    ban_ip "$ip"
                elif (( count > max_attempts )); then
                    echo "[UYARI] -> $ip zaten engelleme listesinde olmalı (Deneme: $count)"
                fi
            fi
        fi
    done < <(tail -n +1 -F "$log_file") 
    # Not: "-n +1" parametresi test kolaylığı için dosyanın başından başlar. 
    # Canlı bir sunucuda sadece YENİ logları görmek için bunu "-n 0" yaparız.
}
