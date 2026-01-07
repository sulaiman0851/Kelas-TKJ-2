# 🚀 KELAS TKJ System v1.0

![Astro](https://img.shields.io/badge/Astro-BC52EE?style=for-the-badge&logo=astro&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/tailwind-%2338B2AC.svg?style=for-the-badge&logo=tailwind-css&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)

**KELAS TKJ** adalah platform manajemen kelas digital yang dirancang khusus untuk jurusan Teknik Komputer dan Jaringan. Aplikasi ini menggabungkan sistem administrasi sekolah, absensi real-time, mading digital, hingga hiburan di Game Room.

---

## ✨ Fitur Unggulan

### 📊 Dashboard Monitoring
Pantau statistik kelas secara langsung! Lihat total siswa, jumlah kehadiran hari ini, dan aktivitas sistem terbaru secara real-time.

### 📝 Mading Kelas & Tugas
Pusat informasi terpadu. Semua pengumuman penting dan tugas sekolah (PR) berkumpul jadi satu di satu feed yang modern dan informatif.

### 📅 Sistem Absensi Digital
Lupakan kertas! Absensi siswa kini lebih mudah dengan fitur check-in digital yang mendukung tampilan desktop maupun mobile (responsive).

### 🎮 Game Room
Ruang hiburan setelah belajar. Terintegrasi dengan game interaktif untuk meningkatkan kekompakan kelas.

### 📰 Blog & Insight
Platform berbagi artikel, panduan teknologi, dan tutorial seputar dunia TKJ.

### 🔐 Admin Control Center
Panel khusus admin untuk mengelola role pengguna, memposting konten mading, dan memantau logging aktivitas sistem.

---

## 🎨 Design System
Aplikasi ini dibangun dengan mengutamakan **Premium UX**:
- **Dark Mode Aesthetic**: Menggunakan palet warna *Slate 950* yang elegan.
- **Glassmorphism UI**: Efek blur dan transparansi pada komponen.
- **Micro-Animations**: Transisi halus dan hover effects yang interaktif.
- **Skeleton Loading**: Menghilangkan visual "kaget" saat data dimuat dari database.

---

## 🛠️ Instalasi & Persiapan

1. **Clone Repository**
   ```bash
   git clone https://github.com/sulaiman0851/Kelas-TKJ-2.git
   cd kelas-tkj
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Konfigurasi Environment**
   Buat file `.env` di root folder dan masukkan kredensial Supabase Anda:
   ```env
   PUBLIC_SUPABASE_URL=your_supabase_url
   PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Jalankan Development Server**
   ```bash
   npm run dev
   ```

---

## 🏗️ Struktur Folder
- `/src/pages`: Routing aplikasi (Dashboard, Blog, Attendance, dll).
- `/src/components`: Komponen modular (Sidebar, Navbar, Loader).
- `/src/layouts`: Template utama aplikasi.
- `/src/lib`: Inisialisasi library (Supabase client).
- `/supabase`: Skema database dan migrasi SQL.

---

## 🤝 Kontribusi
Project ini masih dalam tahap pengembangan. Jika Anda punya ide fitur menarik, jangan ragu untuk membuat *Pull Request*!

---

Developed with ❤️ for **TKJ Community**.
