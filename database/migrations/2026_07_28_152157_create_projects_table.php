<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('project_number')->unique()->nullable();
            $table->string('company_name')->nullable();
            $table->string('pic_name')->nullable();
            $table->string('phone')->nullable();
            $table->string('email_pic')->nullable();
            $table->string('doc_type')->nullable();
            $table->text('additional_notes')->nullable();
            $table->enum('status', ['draft', 'submitted', 'verification', 'under_review', 'approved', 'rejected', 'revision', 'cancelled'])->default('draft')->index();
            $table->foreignUuid('reviewer_id')->nullable()->constrained('users')->nullOnDelete();

            // SLA
            $table->timestamp('target_review_date')->nullable();

            $table->timestamp('submitted_at')->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->timestamp('rejected_at')->nullable();
            $table->integer('revision_count')->default(0);
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};
