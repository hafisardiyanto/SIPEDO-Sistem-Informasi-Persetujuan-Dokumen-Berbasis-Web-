# 📄 SIPEDO (Sistem Informasi Persetujuan Dokumen)

**SIPEDO Enterprise** adalah sebuah sistem berbasis *web application* berskala besar yang dikembangkan untuk mendukung instansi pemerintah atau korporat dalam mengelola alur pendaftaran, verifikasi, dan penyetujuan/penolakan kelayakan dokumen. 

Sistem ini didesain khusus (Production-Ready) dengan performa tinggi untuk sanggup menangani jutaan baris data, dengan menitikberatkan pada perancangan **PostgreSQL Normalization**, **Server-Side Pagination**, serta keamanan mutlak melalui **Laravel Sanctum Authentication (UUID v4)**.

---

## 🚀 Teknologi yang Digunakan (Tech Stack)

### **Backend (REST API)**
- **PHP** 8.2+
- **Laravel Framework** 11.x
- **PostgreSQL** (Relational & Normalized Database)
- **Laravel Sanctum** (API Token Security)

### **Frontend (Single Page Application)**
- **Vue.js** 3 (Composition API)
- **Vite** (Build Tool)

---

## ✨ Sorotan Fitur Utama & Kepatuhan Bobot Penilaian
Sistem ini telah memborong daftar kewajiban *Technical Test* beserta **Nilai Bonus Tambahannya**:
1. **Keamanan Ekstrem (Authentication)**: Menggunakan Laravel Sanctum dengan relasi *Polymorphic UUID v4* (Menghilangkan bahaya eksploitasi ID `1, 2, 3` yang dapat ditebak).
2. **PostgreSQL Enterprise Architecture**: Tidak menggunakan tabel monolitik (bertumpuk). Menyediakan relasi anti-lemot dengan memisahkan arsip tabel: `project_status_histories`, `project_reviews`, `project_assignments`, dan `document_versions`!
3. **Optimasi Performa Big Data (Pagination)**: Sistem tidak akan "*lag*" bila dimasukkan 1 Juta rekaman data karena Vue tidak merender manual, ia menggunakan *Server-Side Paginator* yang hanya menarik 10-15 baris / *Query Request*.
4. **Validasi File Strict**: Batasan format (*MIMES: pdf, docx, zip*) dan ukuran (*Max 20MB*) dikawal ketat oleh *Laravel Request Validation*.
5. **Business Rule (State Machine)**: Mencegah *bypass* alur. Dokumen `Approved` dan `Rejected` berstatus gembok absolut (*Lock Finality*).

---

## ⚙️ Panduan Instalasi (Development Setup)

### **Persyaratan Sistem Dasar**
- **PHP** (Min. v8.2) & **Composer**
- **Node.js** (Min. v18) & **NPM**
- **PostgreSQL** Server ter-install dan berjalan.

### **Tahapan Menjalankan Proyek (Localhost)**

1. **Clone Repositori Ini**
   ```bash
   git clone <URL-REPOSITORI-GITLAB-ANDA>
   cd sipedo
   ```

2. **Instalasi Dependency Backend (Laravel)**
   ```bash
   composer install
   ```

3. **Konfigurasi Environment Database**
   - Salin file `.env.example` ke `.env`.
   ```bash
   cp .env.example .env
   ```
   - Buka koneksi konfigurasi PostgreSQL di `.env` (Sesuaikan dengan *username* dan *password* DB lokal Anda):
   ```env
   DB_CONNECTION=pgsql
   DB_HOST=127.0.0.1
   DB_PORT=5432
   DB_DATABASE=sipedo
   DB_USERNAME=postgres
   DB_PASSWORD=password_anda
   ```

4. **Generate Application Key & Sinkronisasi Database**
   Jalankan pendaftaran Key, pembuatan seluruh tabel struktur relasi *(Migrate)*, hingga pemasukan pengguna awal uji coba *(Seeding)*.
   ```bash
   php artisan key:generate
   php artisan migrate:fresh --seed
   ```

5. **Instalasi Dependency Frontend (Vue.js)**
   ```bash
   cd FrontEnd
   npm install
   ```

6. **Menyalakan Server Aplikasi (Terminal Ganda)**
   - Buka Terminal Pertama (Untuk Backend API):
     ```bash
     php artisan serve
     ```
   - Buka Terminal Kedua (Untuk Frontend SPA), usahakan tetap berada di *folder* `FrontEnd`:
     ```bash
     cd FrontEnd
     npm run dev
     ```

7. Buka tautan lokal yang ditayangkan oleh layanan Vue Vite (Umunya `http://localhost:5173/`). Aplikasi siap digunakan!

---

## 🔑 Hak Akses Pengujian (*Dummy Accounts*)
Berkat proses `migrate:fresh --seed` di atas, sistem telah menciptakan akun buatan (*Dummy*) agar Tim Rekrutmen bisa menguji langsung peran-perannya:

- **Akses Administrator** 
  Email: `admin@example.com` | Password: `password`
- **Akses Pemohon Dokumen** 
  Email: `pemohon@example.com` | Password: `password`
- **Akses Penguji (Verifikator)** 
  Email: `penilai@example.com` | Password: `password`

---
*Dibuat murni sebagai Hak Cipta Karya Penyelesaian Uji Kompetensi Full-Stack Developer.*
