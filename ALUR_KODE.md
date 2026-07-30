# 🗺️ Dokumentasi Pemetaan Alur Kode (Code Flow) & Arsitektur SIPEDO V4

Dokumen ini menjelaskan keseluruhan tata letak, logika aplikasi, pemetaan kontroler dan model, hak akses (role), serta implementasi teknologi mutakhir pada Sistem Informasi Persetujuan Dokumen (SIPEDO) V4.

## 1. Titik Masuk & Hak Akses (Role & Permission)
Aplikasi membagi otorisasi menjadi 3 layer (Role), diproteksi ketat menggunakan Token stateless **Laravel Sanctum**.

*   **Administrator (Admin)**
    *   **Hak Akses**: Akses kontrol penuh. Dapat membuat User baru, menonaktifkan (*suspend*) akun, dan menyetel Master Kategori Dokumen (Pembuatan Jenis Formulir yang muncul di layar klien).
    *   **Data Controller**: `UserController` (CRUD Pegawai) & `DocumentTypeController` (CRUD Master).
*   **Penilai (Auditor/Verifikator)**
    *   **Hak Akses**: Memeriksa, membaca, dan memberikan cap final pada dokumen (Setuju, Revisi, Tolak). Mengakses laporan analitik performa kerja (SLA).
    *   **Data Controller**: `AssessmentLogController` & fitur Export (`ReportController`).
*   **Pemohon (Klien)**
    *   **Hak Akses**: Mengisi formulir entri dokumen, mengunggah lampiran PDF, menyimpan sebagai kepingan `Draft`, lalu mengeksekusinya ke server pusat.
    *   **Data Controller**: `ProjectController`.

## 2. Alur Logika Dari Awal Hingga Akhir (End-to-End Logic Flow)
Seluruh arsitektur aplikasi berangkat dari Front-End (Vue.js) menembus lorong API `routes/api.php` hingga mendarat di database PostgreSQL.

1. **Awal (Registrasi & Login)**
   *   **Alur**: Klien membuka `LoginView.vue` `=>` Mengetik email & kata sandi `=>` Vue melempar kueri Axios `POST /login` `=>` `AuthController.php`.
   *   **Garis Akhir**: Token Sanctum terbit. Klien dialihkan secara paksa oleh *Router Guards* menuju `/pemohon`.
2. **Tahap Penciptaan (Pembuatan Proyek)**
   *   **Alur**: Klien *(Pemohon Dashboard)* mengisi Form. Data jenis dokumen ditarik dari *Model DocumentType* (Master Admin).
   *   **Logic**: Klien menekan "Simpan Draft" atau "Ajukan Permohonan". File biner / lampiran dioper ke `ProjectController@store`.
   *   **Background Worker (Queue)**: Di titik inilah `ProcessDocumentUploadJob.php` bekerja. Daripada membekukan layar Chrome, fungsi *Background Queue* secara asinkron menyedot file tersebut, menggesernya ke Storage Publik, lalu mencetak baris ke tabel struktur database `documents`. 
3. **Fase Evaluasi (Penilaian Penilai)**
   *   **Alur**: Proyek *(Model Project)* berganti wajah dari `draft` menjadi `submitted`. Sang Verifikator *(PenilaiDashboard.vue)* meraup data tersebut dengan mengklik fitur "Ambil Tugas".
   *   **Logic**: Vue menyambung pada rel `AssessmentLogController@evaluate`. Auditor menyuntikkan komentar. Jika ia menekan `Disetujui`, siklus terkunci permanen (*approved*). Jika `Revisi`/`Ditolak`, Pemohon mendapat peringatan perbaikan file.
4. **Tahap Akhir (Puncak Analitik & Database)**
   *   Data bermuara di tabel `projects` dan melahirkan serpihan jejak audit di `project_status_histories` (Untuk fitur pencatatan *Timeline Trail*).
   *   **Stats API**: Dasbor Utama menghitung rasio dokumen *(Approved vs Rejected)* pada Controller `DashboardController.php`. Disinilah fitur pamungkas **Laravel Cache** diinjeksikan agar PostgreSQL tidak kelelahan akibat serangan permintaan agregasi jumlah dokumen gila-gilaan. Memori Cache ini kemudian ditarik oleh visualiasi **ApexCharts** Vue.js di sisi Admin & Penilai!

## 3. Direktori Controller, Model, & Data Yang Disimpan
Rangkuman pilar struktur Back-End:
*   `ProjectController.php`: Jantung Utama. Mengatur CRUD pengajuan dokumen. Menjalankan *Request Validasi*: wajib format mimes (*.pdf, .docx, .png*) dengan ukuran maksimal **20MB**.
*   `DashboardController.php`: Pabrik intelijen kecepatan tinggi. Menggunakan `Cache::remember()` meramu metrik SLA review auditor dan status berkas.
*   `ExportController.php`: Modul canggih yang merubah kumpulan data dari kueri Model `Project` menjadi murni file rekap `Laporan_SIPEDO.xlsx` & cetakan arisan murni `PDF`.
*   `ProcessDocumentUploadJob.php` (Job / Worker): Mengolah lalu-lintas jaringan pemindahan beban file pada disk dari folder `/temp` menuju `/public` melalui antrean asinkron (*Queue Table*) murni bawaan Laravel.

Tabel Basis Data Paling Krusial: `users`, `document_types` (Master admin), `projects` (Data borang utama), `documents` (Tabel fisik lokasi file), `project_status_histories` (Jejak riwayat alur hidup file).

## 4. Evaluasi Uji Fungsional Berkala (The Enterprise Grade Pointers)
Evaluasi terhadap kelulusan teknologi yang ditanamkan dalam repositori lokal saat ini:

*   ✅ **Authentication menggunakan Laravel Sanctum** (Terpasang kuat di Vue & Axios).
*   ✅ **Role & Permission** (Otorisasi kondisional ketat, blokade Controller, & pemutusan pintu vue *Guards*).
*   ✅ **Upload file validation** (Berjalan mutlak pada proteksi validasi bawaan PHP *mimes + max-size*).
*   ✅ **Dashboard menggunakan ApexCharts** (Injeksi interaktif Donat grafik distribusi data di *Penilai* Dashboard `vue3-apexcharts`).
*   ✅ **Export Excel/PDF** (Berjalan secara aktif di latar menggunakan *Maatwebsite* & *BarryVDH* menuju Response Unduhan Web).
*   ✅ **Cache (Redis/Laravel Cache)** (Terinjeksikan pada endpoint agregasi hitungan Dasbor per 60 Detik cache memori).
*   ✅ **Queue untuk unggah/notifikasi** (Struktur migrasi Database Queue & Job *file mover* yang sukses berjalan terpisah).
*   ❌ **Unit Test / Feature Test** (Tidak ada pembukuan test secara otomatis pada iterasi MVP kali ini).
*   ❌ **Docker** (Aplikasi dijalankan natif lewat platform lokal Laragon).
*   ❌ **CI/CD sederhana** (Bukan merupakan objektif pada infrastruktur mesin ini melainkan server).
