# 🗺️ Dokumentasi Pemetaan Alur Kode (Code Flow) SIPEDO

Dokumen ini menjelaskan rancangan alur kerja kode (*code flow*) tingkat lanjut di dalam sistem SIPEDO. Penjelasan dipecah berdasarkan lintas file, secara berurutan mulai dari bagaimana peramban klien (Vue) berinteraksi dengan gerbang *Backend* (Laravel).

---

## 1. Titik Masuk Utama (Entry Points)

Semua pergerakan sistem berawal dari dua file pengatur lalu-lintas (Router/Routes):

*   **`FrontEnd/src/router.js` (Klien SPA Vue 3)**
    *   **Fitur**: Menentukan halaman apa yang muncul di layar (contoh: `/login`, `/dashboard`).
    *   **Logic**: Dilengkapi *Navigation Guards* (Pengecekan di rute). Jika user tidak punya *Token* aktif, paksa kembali ke layar `/login`. Jika mencoba masuk lintas otoritas (misal: Pemohon mengakses *route* Admin), aplikasi secara cerdas mendepaknya.
*   **`routes/api.php` (Peladen Laravel 11)**
    *   **Fitur**: Mendefinisikan pintu-pintu gerbang (*Endpoint REST API*).
    *   **Logic**: Dilindungi seutuhnya oleh identitas *Middleware* otentikasi `auth:sanctum`. Seluruh pertukaran JSON Frontend-Backend wajib melewati blok rute ini.

---

## 2. Alur Akses & Autentikasi (Universal)

Saat seorang masuk ke aplikasi, ini file yang bekerja berkesinambungan:

1.  **`FrontEnd/src/views/LoginView.vue`**
    *   **Fitur**: Halaman antarmuka masukkan formulir Login.
    *   **Alur**: Menangkap nilai `email` & `password` ➔ Melontarkan instruksi `POST /login` via Axios menuju peladen (Server).
2.  **`app/Http/Controllers/AuthController.php`**
    *   **Fitur**: Menerima data kredensial dari `LoginView.vue`.
    *   **Logic**: Mencocokan *Hash Password* di *database* tabel `users`.
    *   **Alur ke**: Jika cocok, menghasilkan *Token Sanctum*. Mengembalikan paket data berisi `(token, role: admin/pemohon/penilai)`.
3.  **Kembali ke `LoginView.vue`**
    *   **Logic (Redirect)**: Frontend menelan token. Merujuk pada data `role` yang diterima, layar menavigasikan URL secara mandiri:
        *   Role Administrator ➔ Diarahkan menuju `/admin`.
        *   Role Pemohon ➔ Diarahkan menuju `/pemohon`.
        *   Role Penilai ➔ Diarahkan menuju `/penilai`.

---

## 3. Alur Fungsionalitas Role: Pemohon

Pemohon membuat dan mengatur Dokumen (Draft & Submission):

1.  **`FrontEnd/src/views/PemohonDashboard.vue`**
    *   **Fitur**: Halaman kontrol Pemohon (Menampilkan keranjang `Draft` dan layar pengunggahan berkas lintas *Drag & Drop*).
    *   **Alur**: Saat pemohon mengisi formulir permohonan baru ➔ Melontarkan `POST /projects` (Simpanan Awal). Menunggah Dokumen ➔ mengirim *MIME Multipart Form* via rute API khusus.
2.  **`app/Http/Controllers/ProjectController.php`** (Method `store` & `submit`)
    *   **Alur ke**: Menyapu permohonan dengan mendaftarkan entitas pada struktur tabel `projects` dan mencetakkan anak-cabang ID turunan ke tabel `documents`.
    *   **Business Rule**: Jika operasi adalah eksekusi pengajuan final (`POST /projects/{id}/submit`), baris proyek beralih status secara resmi (`Draft` ➔ `Submitted`).
3.  **`app/Models/ProjectStatusHistory.php` & `ActivityLog.php`**
    *   **Logic Titik Berhenti**: Setiap mutasi tindakan ini menginvokasi fungsi pencatat di *Controller*. Menyuplai catatan pelaporan ke *database* (`new_status: Submitted`).

---

## 4. Alur Fungsionalitas Role: Administrator

Administrator mengawasi, serta mengangkat penugasan dokumen (`Assign`):

1.  **`FrontEnd/src/views/AdminDashboard.vue`**
    *   **Fitur**: Halaman pengelola sistem (Menu Monitor, Master Data, dsb).
    *   **Alur Data**: Mengektrasi seluruh rekaman permohonan lintas rute `GET /projects`. Meninjau daftar dokumen yang berstatus statis `Submitted`.
2.  **`app/Http/Controllers/ProjectController.php`** (Method `assignReviewer`)
    *   **Fitur**: Administrator menjatuhkan *Assignment*. API mendaratkan kueri *POST*.
    *   **Business Rule & Logic**: Terbatas mutlak pada status proyek `Submitted`! *Controller* memilah profil Penilai, lalu memperbarui tabel: menetapkan tenggat **SLA target_review_date** dan merubah status ke fase transisi (`Submitted` ➔ `Assigned`).
3.  **`app/Models/ProjectAssignment.php`**
    *   **Logic Titik Berhenti**: Mengabadikan rekaman serah terima wewenang penilai baru secara murni melalui integrasi histori ke dalam entitas migrasi SQL ini.

---

## 5. Alur Fungsionalitas Role: Penilai

Penilai bereaksi, merekonstruksi ulasan, hingga mencapai putusan mutlak:

1.  **`FrontEnd/src/views/PenilaiDashboard.vue`**
    *   **Fitur**: Halaman meja operasional evaluasi. Mengusung jendela render `<iframe>` guna implementasi fungsionalitas (Preview PDF Inline) dokumen subjek.
    *   **Alur Data**: Menarik *list* dokumen dari API secara sangat selektif. API `GET /projects` dicampurtangani modifikasi *Authorization Logic*, jadi Penilai hanya diizinkan untuk melihat ID proyek yang mengandung *Foreign Key* `assessor_id` milik dirinya sendiri.
2.  **`app/Http/Controllers/ProjectController.php`** (Method `evaluate`)
    *   **Fitur**: Gerbang putusan akhir permohonan. Menangkap tembakan perintah `Revision`, `Approved`, atau `Rejected` dari form persetujuan layar Penilai.
    *   **Business Rule & Logic**: 
        *   Jika *Approve*: Eksekusi kunci permanen. Tidak boleh diretas manual atau di- *Rollback*. 
        *   Jika *Reject*: Mewajibkan parameter teks berisi komplain alasan jelas pada saat pelontaran API. Form permohonan terkait dinyatakan inaktif total.
        *   Jika *Revision*: Prosedur beralih meluncurkan mekanisme turunan (*Document Versioning*). Memulangkan kordinat status berulang kepada Pemohon untuk diunggah spesifikasi revisinya.
3.  **`app/Models/Notification.php`**
    *   **Fitur Peringatan**: Membangkitkan baris pemberitahuan terotentikasi kepada entitas Profil Pemohon mengenai kesimpulan keputusan yang telah dibuat Penilai.

---

**Ringkasan Lintas Berkas (Perjalanan Sinkron Dokumen):**
> `PemohonDashboard.vue` (Unggah Dokumen) ➔ `ProjectController.php` (Draft/Submit API & Insert SQL) ➔ `AdminDashboard.vue` (Pendelegasian Tugas) ➔ `ProjectController.php` (Assigning, Merubah Model Status, Merumuskan target SLA) ➔ `PenilaiDashboard.vue` (Menganalisis & Vonis) ➔ `Notification.php` (Penutupan Siklus Pemberitahuan).
