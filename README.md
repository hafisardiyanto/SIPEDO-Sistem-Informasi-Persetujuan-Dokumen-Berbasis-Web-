# 📄 SIPEDO (Sistem Informasi Persetujuan Dokumen)

SIPEDO (Sistem Informasi Persetujuan Dokumen) adalah aplikasi berbasis web yang dikembangkan untuk membantu proses pengajuan, verifikasi, review, dan persetujuan dokumen pada instansi pemerintah maupun perusahaan.

Aplikasi ini dibangun menggunakan arsitektur **REST API** dengan **Laravel 11** sebagai Backend dan **Vue 3 (Composition API)** sebagai Frontend Single Page Application (SPA). Seluruh data disimpan menggunakan **PostgreSQL**, sedangkan autentikasi API menggunakan **Laravel Sanctum**.

---

# 🚀 Technology Stack

## Backend

- PHP 8.3
- Laravel Framework 11
- PostgreSQL 15
- Laravel Sanctum
- REST API

## Frontend

- Vue.js 3
- Composition API
- Axios
- Vite

## Development Tools

- Docker & Docker Compose
- Git
- Composer
- NPM

---

# 🏗️ System Architecture

```
Browser
      │
Vue 3 SPA
      │
Axios
      │
REST API
      │
Laravel 11
      │
Controller
      │
Model
      │
PostgreSQL
```

Frontend tidak pernah mengakses database secara langsung.

Seluruh komunikasi dilakukan melalui REST API menggunakan format JSON sehingga frontend dan backend dapat dikembangkan secara terpisah.

---

# ✨ Fitur Utama

## Authentication

- Login menggunakan Laravel Sanctum
- Bearer Token Authentication
- Role Based Access
- UUID sebagai Primary Key

---

## Dashboard

- Dashboard Admin
- Dashboard Pemohon
- Dashboard Penilai
- Statistik Data
- Monitoring Status Dokumen

---

## Manajemen Project

- CRUD Project
- Upload Multi Dokumen
- Submit Project
- History Status
- Recycle Bin
- Restore Data

---

## Review Dokumen

- Assign Penilai
- Approve
- Reject
- Revision
- Assessment History

---

## Master Data

- Master User
- Master Jenis Dokumen

---

# ⚡ Implementasi Requirement Technical Test

Aplikasi ini mengimplementasikan seluruh kebutuhan utama Technical Test.

| Feature | Status |
|---------|:------:|
| Laravel 11 | ✅ |
| PHP 8.2+ | ✅ |
| Vue 3 | ✅ |
| PostgreSQL | ✅ |
| REST API | ✅ |
| Git | ✅ |
| Sanctum Authentication | ✅ |
| Upload File Validation | ✅ |
| Pagination | ✅ |
| Queue Upload | ✅ |
| Soft Delete | ✅ |
| UUID | ✅ |
| Docker | ✅ |
| Export Excel | ✅ |
| Export PDF | ✅ |

---

# 🔐 Authentication

Authentication menggunakan Laravel Sanctum.

Setelah user berhasil login, sistem akan menghasilkan API Token.

Seluruh endpoint yang bersifat private dilindungi menggunakan middleware.

```php
Route::middleware('auth:sanctum')
```

Token harus dikirim melalui Authorization Header.

```
Authorization: Bearer {token}
```

---

# 📂 Database Design

Database menggunakan PostgreSQL.

Struktur utama terdiri dari beberapa tabel yang telah dinormalisasi.

```
users
    │
    └── projects
            │
            ├── documents
            │
            ├── assessment_logs
            │
            ├── project_status_histories
            │
            └── project_assignments

document_types
```

Relasi utama:

- Satu User memiliki banyak Project
- Satu Project memiliki banyak Document
- Satu Project memiliki banyak Assessment Log
- Satu Project memiliki banyak Status History

Dengan struktur ini data menjadi lebih terorganisir dan mengurangi duplikasi data.

---

# ⚙️ Optimasi Performa

Aplikasi menerapkan beberapa optimasi performa.

## Server Side Pagination

```php
Project::latest()->paginate(10);
```

Pagination dilakukan di server sehingga frontend hanya menerima data yang dibutuhkan.

---

## Eager Loading

```php
Project::with('documents');
```

Digunakan untuk menghindari N+1 Query sehingga jumlah query database menjadi lebih efisien.

---

## Database Transaction

```php
DB::beginTransaction();
```

Digunakan agar proses penyimpanan Project dan Upload Dokumen tetap konsisten.

Jika terjadi error maka seluruh proses akan dibatalkan menggunakan rollback.

---

## Queue

```php
ProcessDocumentUploadJob::dispatch(...)
```

Upload dokumen diproses di background menggunakan Queue sehingga response API tetap cepat.

---

## Soft Delete

```php
use SoftDeletes;
```

Data tidak langsung dihapus dari database tetapi dipindahkan ke Recycle Bin sehingga dapat dipulihkan kembali.

---

# 📁 Upload Dokumen

Validasi file dilakukan menggunakan Laravel Validation.

Format file:

- PDF
- DOC
- DOCX
- ZIP
- RAR
- JPG
- PNG

Ukuran maksimal:

```
20 MB
```

Hal ini bertujuan menjaga keamanan dan konsistensi data.

---

# 📦 REST API

Contoh endpoint yang tersedia.

## Authentication

```
POST    /api/login
POST    /api/logout
GET     /api/profile
```

## Project

```
GET     /api/projects
POST    /api/projects
POST    /api/projects/{id}
DELETE  /api/projects/{id}
POST    /api/projects/{id}/submit
GET     /api/projects/{id}/history
POST    /api/projects/{id}/restore
```

## Assessment

```
GET     /api/assessments
POST    /api/assessments/{project}/evaluate
```

## Admin

```
GET     /api/admin/users
POST    /api/admin/users
PUT     /api/admin/users/{id}
DELETE  /api/admin/users/{id}
```

---

# 🐳 Docker

Project dapat dijalankan menggunakan Docker Compose.

Menjalankan seluruh service.

```bash
docker compose up -d --build
```

Menjalankan migration.

```bash
docker exec -it sipedo_app php artisan migrate --seed
```

Service yang digunakan:

- Laravel App
- Nginx
- PostgreSQL
- PgAdmin

Arsitektur Docker.

```
Browser
      │
Nginx
      │
Laravel
      │
PostgreSQL
```

---

# ⚙️ Installation

Clone repository.

```bash
git clone <repository-url>
```

Masuk ke project.

```bash
cd sipedo
```

Install dependency backend.

```bash
composer install
```

Copy environment.

```bash
cp .env.example .env
```

Generate key.

```bash
php artisan key:generate
```

Migration.

```bash
php artisan migrate --seed
```

Install frontend.

```bash
cd FrontEnd
npm install
```

Menjalankan frontend.

```bash
npm run dev
```

Backend.

```bash
php artisan serve
```

---

# 👤 Dummy Account

## Administrator

```
Email
admin@example.com

Password
password
```

---

## Pemohon

```
Email
pemohon@example.com

Password
password
```

---

## Penilai

```
Email
penilai@example.com

Password
password
```

---

# 📁 Struktur Project

```
app/
├── Http/
├── Models/
├── Jobs/
├── Notifications/

database/
├── migrations/
├── seeders/

routes/
├── api.php

resources/

FrontEnd/
├── src/
├── components/
├── views/

docker/
├── nginx/

docker-compose.yml
```

---

# 📚 Catatan

Selama pengembangan aplikasi ini diterapkan beberapa best practice Laravel, di antaranya:

- REST API Architecture
- Laravel Sanctum Authentication
- UUID Primary Key
- Server Side Pagination
- Eager Loading
- Database Transaction
- Queue Background Job
- Soft Delete
- File Validation
- Role Based Access Control
- Docker Environment

---

# 👨‍💻 Developer

**Hafis Ardiyanto**

Technical Test – Full Stack Developer

Laravel 11 • Vue 3 • PostgreSQL • REST API • Docker