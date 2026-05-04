# Tempura IoT Fermentation System 🌡️🌿

Tempura adalah sistem monitoring fermentasi tempe berbasis IoT (Internet of Things). Sistem ini dirancang untuk memantau kondisi lingkungan fermentasi secara real-time (Suhu, Kelembaban, dan Kelembaban Tempe) guna memastikan kualitas tempe yang optimal.

## ✨ Fitur Utama

- **Premium Monitoring Dashboard**: Visualisasi data sensor (Suhu, Kelembaban, Kelembaban Tempe) melalui antarmuka mobile yang modern dengan sistem **Sliver Smooth Scrolling**.
- **Interactive Device Control**: Kendali perangkat pendukung (Kipas Utama, Pompa Mist, Bohlam UV) dengan **Micro-Animations** (Ikon berputar, berdenyut, dan bercahaya saat aktif).
- **ESP32 Connection Guard**: Pemantauan status koneksi hardware secara real-time melalui kartu status khusus.
- **Advanced Authentication**:
  - **Session Persistence**: Sistem "Ingatan" sesi yang memungkinkan pengguna masuk otomatis tanpa login ulang.
  - **Dynamic Roles**: Identifikasi peran pengguna (**Pemilik/Admin** & **Pegawai**) secara dinamis.
  - **3-Step Password Recovery**: Alur lupa kata sandi yang aman dengan verifikasi **6-Digit OTP** dan halaman reset khusus.
- **Reusable Batch Templates**: Gunakan kembali pengaturan batch yang sukses (Jumlah bungkus, kedelai, ragi) berkali-kali.
- **Riwayat Produksi**: Catatan detail setiap sesi fermentasi, termasuk waktu mulai, selesai, dan status keberhasilan.
- **Smart Harvesting**: 
  - **Otomatis**: Sistem mendeteksi kesiapan panen berdasarkan sensor dan mengakhiri batch secara otomatis.
  - **Manual**: Pengguna dapat menghentikan proses secara paksa (emergency stop).

## 🛠️ Tech Stack

### Backend
- **Language**: [Golang](https://go.dev/)
- **Framework**: [Gin Gonic](https://gin-gonic.com/)
- **Database**: [PostgreSQL](https://www.postgresql.org/) (via [Supabase](https://supabase.com/))
- **ORM**: [GORM](https://gorm.io/)
- **Communication**: [MQTT](https://mqtt.org/) untuk data IoT real-time.

### Mobile App
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: BLoC / StatefulWidget
- **Networking**: [Dio](https://pub.dev/packages/dio) & [Supabase Auth](https://supabase.com/docs/reference/dart/auth-updateuser)
- **Design System**: Premium Dark Theme dengan aksen Vibrant Gold.

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
- [x] Dashboard Monitoring Premium dengan Micro-Animations
- [x] Sistem Autentikasi & Session Persistence (Auto-Login)
- [x] Alur Verifikasi OTP & Reset Password Mandiri
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
