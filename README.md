# Tempura IoT Fermentation System 🌡️🌿

Tempura adalah sistem monitoring fermentasi tempe berbasis IoT (Internet of Things). Sistem ini dirancang untuk memantau kondisi lingkungan fermentasi secara real-time (Suhu, Kelembaban, dan Kelembaban Tanah) guna memastikan kualitas tempe yang optimal.

## ✨ Fitur Utama

- **Monitoring Real-time**: Visualisasi data sensor (Suhu, Kelembaban, Soil Moisture) melalui dashboard mobile yang premium.
- **Reusable Batch Templates**: Gunakan kembali pengaturan batch yang sukses (Jumlah bungkus, kedelai, ragi) berkali-kali.
- **Riwayat Produksi**: Catatan detail setiap sesi fermentasi, termasuk waktu mulai, selesai, dan status keberhasilan.
- **Smart Harvesting**: 
  - **Otomatis**: Sistem mendeteksi kesiapan panen berdasarkan sensor dan mengakhiri batch secara otomatis.
  - **Manual**: Pengguna dapat menghentikan proses secara paksa (emergency stop).
- **Manajemen Perangkat**: Kendali perangkat pendukung (Lampu/Kipas) langsung dari aplikasi.
- **Sistem Autentikasi Aman**: Login pengguna dan fitur permintaan reset password melalui admin.

## 🛠️ Tech Stack

### Backend
- **Language**: [Golang](https://go.dev/)
- **Framework**: [Gin Gonic](https://gin-gonic.com/)
- **Database**: [PostgreSQL](https://www.postgresql.org/) (via [Supabase](https://supabase.com/))
- **ORM**: [GORM](https://gorm.io/)
- **Communication**: [MQTT](https://mqtt.org/) untuk data IoT.

### Mobile App
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: Provider / StatefulWidget
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Design System**: Premium Dark Theme dengan aksen Gold.

## 🚀 Cara Menjalankan

### Persiapan Database
1. Buat project baru di Supabase.
2. Dapatkan kredensial database (Host, User, Password, Port).
3. Masukkan kredensial ke file `backend/.env`.

### Menjalankan Backend
```bash
cd backend
go mod tidy
go run main.go
```

### Menjalankan Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

## 📈 Progres Pengembangan

- [x] Inisialisasi Project & Arsitektur Monorepo
- [x] Integrasi MQTT & Sensor Ingestion
- [x] Sistem Reusable Batch & Production History
- [x] Dashboard Monitoring Premium
- [x] Fitur Reset Password via Admin
- [x] Auto-Harvest Logic (Soil Moisture Trigger)
- [ ] Implementasi Push Notification (Next Phase)
- [ ] Laporan Statistik Mingguan (Next Phase)

## 👤 Kontributor
- R. Jodie Ferdyanto Susilo    (PROJECT MANAGER)
- Khayru Nabiel Bahtiar        (UIUX DESAINER)
- Firsandi Andraw Febriansyah  (PROGRAMMER IoT & TEMPURA MOBILE APP)
- Dimas Rofi’ Purnomo          (SYSTEM ANALYST)
 

---
*Dibuat dengan ❤️ untuk kemajuan industri tempe Indonesia.*
