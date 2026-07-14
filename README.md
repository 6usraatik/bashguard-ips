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
