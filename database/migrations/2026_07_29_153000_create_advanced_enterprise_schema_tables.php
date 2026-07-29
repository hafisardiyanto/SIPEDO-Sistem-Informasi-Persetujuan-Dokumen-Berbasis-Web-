<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        // 1. Tambah Atribut Status Aktif Pada User
        if (!Schema::hasColumn('users', 'is_active')) {
            Schema::table('users', function (Blueprint $table) {
                $table->boolean('is_active')->default(true)->after('role')->comment('Toggle nonaktifkan entitas pekerja saat resign tanpa menghapus audit trail.');
            });
        }

        // 2. Tabel Project Assignments (Menanggulangi Re-Assignment History)
        if (!Schema::hasTable('project_assignments')) {
            Schema::create('project_assignments', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('project_id');
                $table->uuid('assessor_id')->comment('Penilai Baru (Re-Assigned)');
                $table->uuid('old_assessor_id')->nullable()->comment('Penilai Lama');
                $table->uuid('assigned_by')->comment('Administrator yang melakukan penugasan');
                $table->text('reason')->nullable()->comment('Argumentasi pindah tugas wajib disematkan');
                $table->timestamps(); // Termasuk assigned_at (created_at)

                $table->foreign('project_id')->references('id')->on('projects')->onDelete('cascade');
                $table->foreign('assessor_id')->references('id')->on('users')->onDelete('cascade');
                $table->foreign('assigned_by')->references('id')->on('users')->onDelete('cascade');
            });
        }

        // 3. Document Versioning (Revisi Multi-Lapisan)
        if (Schema::hasTable('documents') && !Schema::hasColumn('documents', 'version')) {
            Schema::table('documents', function (Blueprint $table) {
                $table->unsignedInteger('version')->default(1)->after('file_name')->comment('Tracing hierarki revisi berkas v1, v2 tanpa timpa ulang');
            });
        }

        // 4. Spesifikasi Master Data Kategori
        if (!Schema::hasTable('document_categories')) {
            Schema::create('document_categories', function (Blueprint $table) {
                $table->id();
                $table->string('name')->unique();
                $table->text('description')->nullable();
                $table->timestamps();
            });
        }

        // 5. Rekam Review Histori 
        if (!Schema::hasTable('project_reviews')) {
            Schema::create('project_reviews', function (Blueprint $table) {
                $table->uuid('id')->primary();
                $table->uuid('project_id');
                $table->uuid('reviewer_id');
                $table->string('status_given')->comment('Misal: revision, approved');
                $table->integer('review_cycle')->default(1)->comment('Siklus Review ke-1, Review 2, dsb');
                $table->text('notes')->nullable();
                $table->timestamps();

                $table->foreign('project_id')->references('id')->on('projects')->onDelete('cascade');
            });
        }
    }

    public function down()
    {
        Schema::dropIfExists('project_reviews');
        Schema::dropIfExists('document_categories');
        if (Schema::hasColumn('documents', 'version')) {
            Schema::table('documents', function (Blueprint $table) {
                $table->dropColumn('version'); });
        }
        Schema::dropIfExists('project_assignments');
        if (Schema::hasColumn('users', 'is_active')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('is_active'); });
        }
    }
};
