# Dokumentasi Arsitektur & Alur Kerja Lengkap SIPEDO (Sistem Informasi Persetujuan Dokumen)

Dokumen ini merangkum pergerakan siklus data *(Data Lifecycle)*, alur logika (*Business Logic*), dan pembagian peran (*Authorization*) dari kedua ujung aplikasi: **Frontend (Vue.js)** sebagai antarmuka dan **Backend (Laravel 11)** sebagai inti pemrosesan API.

---

## DAFTAR ISI (Modul Sistem)
1. [Arsitektur Keseluruhan (SPA + API)](#1-arsitektur-keseluruhan-spa--api)
2. [Alur Autentikasi (Login & Sesi)](#2-alur-autentikasi-login--sesi)
3. [Alur Utama Pemohon: Pengajuan Proyek](#3-alur-utama-pemohon-pengajuan-proyek)
4. [Alur Penilai: Evaluasi & Log Penilaian](#4-alur-penilai-evaluasi--log-penilaian)
5. [Alur Admin: Manajemen Pengguna & Referensi (Document Types)](#5-alur-admin-manajemen-pengguna--referensi-document-types)
6. [Alur Dashboard, Statistik, & Notifikasi](#6-alur-dashboard-statistik--notifikasi)
7. [Alur Pelaporan & Ekspor Data](#7-alur-pelaporan--ekspor-data)

---

## 1. Arsitektur Keseluruhan (SPA + API)

SIPEDO menggunakan struktur moduler berbasis *RESTful API*:
- **Aktor Frontend:** Bertanggung jawab penuh melukiskan DOM (tampilan tabel, peringatan, kotak pengajuan). Seluruh komunikasi di dalam Vue dikelola oleh *Axios*, yang menyematkan `Bearer Token` atau `Sanctum Cookie` secara senyap (*interceptors*) pada semua rute, terpusat di `main.js`.
- **Nginx Reverse Proxy:** Mencegat alamat di port `8094`. Apabila alamat yang diminta diawali `/api` atau `/sanctum`, Nginx meneruskannya ke mesin PHP-FPM (Container Laravel `sipedo_app` port 9000). Jika tidak, Nginx memberikan file Vue (`index.html`).
- **Aktor Backend:** Laravel mengesampingkan pembuatan antarmuka (tidak ada view Blade yang signifikan). Fokus menerima paket JSON, melakukan *Database Query* via Eloquent ORM, dan membungkus hasil respons (*Response JSON*). 

---

## 2. Alur Autentikasi (Login & Sesi)
**Tujuan Berkas:** Mengamankan setiap jalan masuk aplikasi dari penyusup, serta mengenali level (*Role*) secara ketat.

* **Frontend:** `LoginView.vue`
* **Router API:** `routes/api.php`
* **Controller:** `app/Http/Controllers/AuthController.php`

**Kronologi Kerja:**
1. Pengguna memasukkan sandi di *browser*. 
2. Vue diam-diam mengontak `/sanctum/csrf-cookie` untuk mengambil jaminan anti-pembajakan formulir, dilanjut dengan request `POST /api/login`.
3. Di `AuthController::login`, metode `Auth::attempt()` melakukan pencarian ganda (Apakah email ada di tabel `users`? Apakah `Hash` sandi sama?).
4. Jika berpapasan (*Match*), Sanctum meredam Token Privat lewat `$user->createToken('auth_token')->plainTextToken`.
5. JSON respons (Token & Profil Identitas) dilempar ke Vue ➔  Disimpan di `localStorage` ➔ Vue Router segera mem-`push` ke URL `/pemohon/dashboard` (atau peran terkait).

---

## 3. Alur Utama Pemohon: Pengajuan Proyek
**Tujuan Berkas:** Mewadahi Pemohon (*Applicant*) untuk membuat pengajuan berkas baru, mengirim dokumen lampiran kelayakan.

* **Frontend:** Component `PemohonDashboard.vue`, Formulir Unggah.
* **Controller Inti:** `app/Http/Controllers/ProjectController.php`
* **Kaitan Model:** `Project`, `Document`, `User`

**Kronologi Kerja (Skenario Submit Pengajuan):**
1. Pemohon mengisi detail proyek dan dokumen di antarmuka Vue ➔ Menekan *Submit*.
2. Vue menggunakan `FormData` JavaScript untuk menempelkan teks sekaligus File yang diunggah ➔ Dikirim ke `POST /api/projects`.
3. Di dalam ruang mesin Laravel, `ProjectController::store` dipanggil.
4. **Validasi (Proteksi Awal):** Laravel secara ketat memeriksa tipe berkas, ukuran unggahan, kelengkapan format.
5. **Transaksi Basis Data:** `DB::beginTransaction()` mendikte agar seluruh pencatatan harus mulus; jika ada error unggah file, SQL tidak akan merekam data setengah matang.
6. Laravel membuat baris di tabel `projects`. 
7. Sistem file (`Storage::disk('local/s3')`) mengamankan fail, dan merekam rutenya ke dalam tabel `documents` menggunakan perulangan *(foreach)*.
8. Status default `"draft"` atau `"in_review"` tersemat. Hasil sukses dilempar lagi ke layar pemohon sebagai *SweetAlert/Toaster*.

*(Terdapat juga fungsi lain seperti `history`, `trash`, dan `restore` untuk memanajemen arsip lama).*

---

## 4. Alur Penilai: Evaluasi & Log Penilaian
**Tujuan Berkas:** Mengaudisi kelayakan dokumen yang dilempar pemohon, lalu menerima/menolak seutuhnya yang dikawal riwayat transparan (Audit Trail).

* **Frontend:** `PenilaiDashboard.vue` dan Detail Evaluasi.
* **Controller Inti:** `app/Http/Controllers/AssessmentLogController.php`
* **Kaitan Model:** `AssessmentLog`, `Project`

**Kronologi Kerja:**
1. Rute *Penilai* memblokir siapa saja di luar `role===penilai` sejak di penjaga pintu (`Auth::user()->role !== 'penilai'`).
2. Penilai mengeklik "Buat Evaluasi". Mengirim `status` dan `notes` ke `POST /api/assessments/{project}/evaluate`.
3. Di dalam `AssessmentLogController`, blok validasi wajib menyuruh *Reviewer* menyertakan 'Catatan' manakala ia memilih menjatuhkan status 'Revisi' atau 'Ditolak'.
4. Menggunakan `DB::beginTransaction()`, 2 proses sakral bersentuhan dengan database:
   - Data baris dari tabel `projects` ditimpa status barunya (`revision_count` bertambah jika revisi).
   - Tabel `assessment_logs` dibuat persis menyalin detik kejatuhan palu tersebut, lengkap dengan `ip_address` evaluator dan `status_from` ke `status_to`, merekam jejak siapa yang menyetujuinya.

---

## 5. Alur Admin: Manajemen Pengguna & Referensi (Document Types)
**Tujuan Berkas:** "Ruang mesin" pengelola untuk melakukan pendaftaran aktor sistem dan kriteria kategori lampiran. 

* **Frontend:** `AdminDashboard.vue` dan menu-menu Manajer.
* **Controller Inti:** `app/Http/Controllers/Admin/UserController.php`, `DocumentTypeController.php`

**Kronologi Kerja:**
1. Akun Admin terpusat pada Route Group dengan `prefix('admin')` pada `api.php`.
2. Admin dapat mengubah *Role* Pemohon (memulihkan, membekukan menggunakan *soft-deletes* / `toggleStatus`).
3. Pada `DocumentTypeController`, tabel `document_types` dikelola (CRUD). Admin secara berkala mendefinisikan apa saja dokumen pengajuan yang sah. 

---

## 6. Alur Dashboard, Statistik, & Notifikasi
**Tujuan Berkas:** Fitur asisten kosmetik untuk pengalaman pengguna, pelunasan notifikasi lonceng & hitungan grafik.

* **Controller Inti:** `DashboardController.php`, `NotificationController.php`

**Kronologi Kerja:**
1. Di setiap layar masuk utama Vue mengontak `GET /api/dashboard/stats`.
2. `DashboardController` menjalankan `COUNT()` pada Model, menghitung rasio jumlah dokumen diproses, tertunda, ditolak, dsb. Disajikan dalam sekali napas (*Batch JSON*) agar Grafik chart.js atau ApexCharts bisa melukisnya serempak.
3. Saat *Penilai* mengubah status, sistem (*Observer* atau langsung via Controller) memantik rekaman ke tabel notifikasi bersangkutan (Bagi pemohon X: *"Dokumen Anda ditolak!"*).
4. `NotificationController` menangani indikator "*Unread Badge*" dengan aksi `markAsRead` ketika si pengguna Vue membuka layarnya.

---

## 7. Alur Pelaporan & Ekspor Data
**Tujuan Berkas:** Mencetak rekap evaluasi secara terhitung massal dari *Query SQL* padat.

* **Controller Inti:** `ExportController.php`

**Kronologi Kerja:**
1. Vue melayangkan permintaan (biasanya dengan token akses, atau khusus disiapkan sebagai publik khusus pada demo).
2. Membidik `GET /api/export/excel` atau `pdf`.
3. Eloquent merakit Eager Loading bertumpuk lalu mengumpankannya ke antarmuka ekstensi Laravel Excel/DomPDF. 
4. Merespon aliran *(Stream)* data berkas biner `.xlsx`/ `.pdf` ke peramban (*browser*) agar segera diproses dialog kotak "Save As...".

---

**(Penutup Cepat):** Seluruh komunikasi dari nomor 1 sampai 7 berjalan amat steril, karena jika terjadi Error 500 (*Exception*) di backend `try-catch`, sistem ORM akan merobohkan perubahan via `DB::rollBack()` dan mengembalikan format `{"message": "Error ..."}` yang elegan agar *Toast Notification* di Vue JS bisa memberi tahu pengguna tanpa membuat halamannya patah!
