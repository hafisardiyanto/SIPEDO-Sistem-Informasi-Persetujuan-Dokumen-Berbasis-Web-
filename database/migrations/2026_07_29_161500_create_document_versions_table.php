<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        // 1. Ekstraksi Tabel Document Versioning
        if (!Schema::hasTable('document_versions')) {
            Schema::create('document_versions', function (Blueprint $table) {
                $table->id();
                $table->uuid('document_id');
                $table->integer('version')->default(1);
                $table->string('file_path');
                $table->uuid('uploaded_by')->nullable();
                $table->timestamps(); // uploaded_at

                $table->foreign('document_id')->references('id')->on('documents')->onDelete('cascade');
                $table->foreign('uploaded_by')->references('id')->on('users')->onDelete('set null');
            });
        }
    }

    public function down()
    {
        Schema::dropIfExists('document_versions');
    }
};
