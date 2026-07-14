# 🛡️ BashGuard-IPS: Autonomous Log Analyzer & Firewall Blocking Engine

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash_Scripting-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Systemd](https://img.shields.io/badge/Systemd-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Security](https://img.shields.io/badge/Blue_Team-SIEM%20%26%20IPS-0052CC?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production_Ready-22c55e?style=for-the-badge)

**BashGuard-IPS**, Linux sistem loglarını sıfır gecikmeyle izleyen, anomali ve kaba kuvvet (brute-force) saldırı örüntülerini algılayan ve eşik değeri aşıldığında sistemin güvenlik duvarına (`iptables`) otonom kurallar yazarak saldırganları anında engellemeyi sağlayan, hafif ve bağımsız bir **Blue Team IPS (Saldırı Engelleme Sistemi)** projesidir.

> 💡 **Geliştirme Felsefesi:** Bu proje; hazır araçlara (Fail2ban, Snort vb.) sırtını yaslamak yerine, Linux ağ yığıtının, bellek yönetiminin, asenkron alt süreçlerin ve sistem çekirdeği entegrasyonunun derinliklerini kavrama amacıyla sıfırdan inşa edilmiştir.

---

## 🏛️ Sistem Mimarisi ve Çalma Akışı

BashGuard-IPS, tek bir devasa betik yerine, birbirine entegre 4 mantıksal katman üzerinden hizmet verir:

```text
[ Log Kaynakları ] -> (1. Sensör Motoru) -> [ Canlı Akış & Regex ]
                            ↓
                     (2. Analiz Motoru) -> [ RAM (Associative Array) Eşik Kontrolü ]
                                                    ↓
[ iptables (BASHGUARD_IPS) ] <- (3. İnfaz Motoru) <- [ Ban Kararı & DB Kaydı ]
        ↓
(4. Af Motoru / Reaper) -> [ Süresi Dolan IP'lerin Engelini Kaldır ]

Sensör Motoru (tail -F): Log Rotation (dosya silinip yeniden yazılma) durumlarında dahi inode takibi yaparak log okumayı kesintisiz sürdürür.

Analiz Motoru (state.sh): Process Substitution < <(...) mimarisi sayesinde alt kabuk (subshell) tuzağına düşmeden, saldırgan IP'lerini ve anlık ihlal sayılarını doğrudan ana kabuğun hafızasında (Associative Array) tutar.

İnfaz Motoru (firewall.sh): Sistemin mevcut kurallarını bozmamak için kendisine özel BASHGUARD_IPS adında izole bir zincir kurar. Saldırganın IP'sini listenin en tepesine (-I) çakarak trafiği anında imha (DROP) eder.

Af Motoru / Reaper (reaper.sh): Arka planda (&) çalışan asenkron bir temizlikçidir. Unix Epoch zamanını (date +%s) denetleyerek engelleme süresi dolan IP'leri ağdan otomatik temizler.
```

## ✨ Öne Çıkan Mühendislik Özellikleri

🛡️ Defensive Scripting (set -euo pipefail): Tanımsız değişken kullanımını ve boru hattı (pipeline) kırılmalarını anında yakalar; olası sistem arızalarının veya veri kayıplarının önüne geçer.

⚡ Sıfır Bağımlılık (Zero-Dependency): Python veya harici kütüphaneler gerektirmez. Doğrudan Linux çekirdeği ve yerleşik metin işleme araçlarıyla (grep, awk, sed, sort, uniq) maksimum hızda çalışır.

🔒 İzole Firewall Yönetimi: Sistemdeki diğer iptables kurallarına dokunmaz, aracı kaldırdığınızda sadece kendi zincirini temizler.

🚨 Dry-Run (Simülasyon) Modu: Gerçek sunucu ortamına geçmeden önce komutları çalıştırmadan simüle ederek güvenli test imkanı sunar.

💀 Graceful Shutdown (trap): CTRL+C veya servis durdurma sinyali (SIGINT/SIGTERM) geldiğinde arka plandaki alt süreçleri (Reaper) öldürerek sistemde "yetim süreç" (zombie process) bırakmaz.

🔄 Systemd Entegrasyonu (Restart=always): Sunucu yeniden başlasa veya çökse dahi Linux çekirdeği tarafından 3 saniye içinde yeniden diriltilen 7/24 aktif bir daemon'dır.


## 🚀 Kurulum ve Kullanım
1. Depoyu Kopyalayın 
````
git clone [https://github.com/6usraatik/bashguard-ips.git](https://github.com/6usraatik/bashguard-ips.git)
cd bashguard-ips
````
2. Tek Komutla Sistem Servisi Olarak Kurun
Kurulum betiği, dosyaları sistemin /opt/bashguard-ips dizinine taşır, izinleri ayarlar ve systemd servisini aktifleştirir:

````
sudo ./install.sh
````
3. Servis Durumunu ve Canlı Logları İzleyin

[Servisin aktiflik durumunu kontrol edin]
````
sudo systemctl status bashguard
````
[Arka planda gerçekleşen anlık engellemeleri canlı izleyin]
````
sudo journalctl -u bashguard -f
````

## 📊 CLI Özet Panosu (Dashboard)
Aracın arka planda ne yaptığını tek bakışta görmek için özel durum panosunu çalıştırabilirsiniz:
````
sudo /opt/bashguard-ips/status.sh
````
Örnek Ekran Çıktısı:

````
====================================================
         BASHGUARD-IPS CANLI DURUM PANOSU           
====================================================
 -> Servis Durumu  : ● AKTİF (Çalışıyor)
 -> Firewall Zinciri: AKTİF (İnfaz Kuralları: 2)
----------------------------------------------------
 AKTİF ENGEL KULLANICI LİSTESİ (BANNED IPs)
----------------------------------------------------
ENGELLEME TARİHİ	BİTİŞ SÜRESİ	IP ADRESİ
----------------------------------------------------
2026-07-14 11:40:00	~45 dk kaldı	198.51.100.22
2026-07-14 11:42:15	~58 dk kaldı	203.0.113.45
====================================================
````


## ⚙️ Yapılandırma (bashguard.conf)
Aracın davranışlarını /opt/bashguard-ips/conf/bashguard.conf dosyası üzerinden anlık olarak özelleştirebilirsiniz:

[İzlenecek hedef log dosyası (Örn: SSH veya Web Sunucusu)]
````
LOG_FILE="/var/log/auth.log"
````
[Bir IP'nin engellenmesi için gereken maksimum ihlal sayısı]
````
MAX_ATTEMPTS=5
````

[Engelleme süresi (Saniye cinsinden - Örn: 3600 = 1 saat)]
````
BAN_TIME=3600
````

["true": Sadece ekrana yazar (Tatbikat modu) | "false": Gerçek firewall ban atar]
````
DRY_RUN="false"
````

## 🧹 Sistemden Kaldırma (Uninstallation)

Sistemi iz bırakmadan ve firewall kurallarını orijinal haline döndürerek temizlemek için:
````
sudo ./uninstall.sh
````
