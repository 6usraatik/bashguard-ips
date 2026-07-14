#!/usr/bin/env bash

set -euo pipefail

# Konfigürasyon dosyasını güvenli bir şekilde yükleyen fonksiyon
load_config() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        echo "[BİLGİ] Yapilandirma yuklendi: $config_file"
    else
        echo "[HATA] Yapilandirma dosyasi bulunamadi: $config_file" >&2
        exit 1
    fi
}
