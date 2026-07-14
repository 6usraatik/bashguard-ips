#!/usr/bin/env bash

# defensive scripting
set -euo pipefail

# "Failed password" ifadesi geçen satırlardan IP çekmek için
# 4 blok halinde sayılardan (0-255) oluşan IP formatını arar.
IP_REGEX="([0-9]{1,3}\.){3}[0-9]{1,3}"

parse_ssh_failures() {
    local log_file="$1"

    if [[ ! -f "$log_file" ]]; then
        echo "[HATA] Log dosyasi bulunamadi: $log_file" >&2
        return 1
    fi

    echo "=== SSH Saldiri Analizi Baslatiliyor ==="
    echo "İncelenen Log: $log_file"
    echo "----------------------------------------"
    echo -e "SALDIRI SAYISI\tSALDIRGAN IP"
    echo "----------------------------------------"
    

    grep "Failed password" "$log_file" \
        | grep -oE "$IP_REGEX" \
        | sort \
        | uniq -c \
        | sort -nr
}
