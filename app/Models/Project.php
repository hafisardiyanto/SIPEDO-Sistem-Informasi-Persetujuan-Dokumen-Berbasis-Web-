<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\SoftDeletes;

class Project extends Model
{
    use HasFactory, HasUuids, SoftDeletes;

    protected $fillable = [
        'user_id',
        'project_number',
        'title',
        'company_name',
        'pic_name',
        'phone',
        'email_pic',
        'doc_type',
        'description',
        'additional_notes',
        'status',
        'deadline_date',
        'reviewer_id',
        'submitted_at',
        'reviewed_at',
        'approved_at',
        'rejected_at',
        'revision_count'
    ];

    protected static function booted()
    {
        static::creating(function ($project) {
            if (!$project->project_number) {
                $date = now()->format('Ymd');
                $lastProject = self::whereDate('created_at', now()->toDateString())->orderBy('id', 'desc')->first();
                $number = $lastProject ? (int) substr($lastProject->project_number, -6) + 1 : 1;
                $project->project_number = 'DOC-' . $date . '-' . str_pad($number, 6, '0', STR_PAD_LEFT);
            }
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function documents()
    {
        return $this->hasMany(Document::class);
    }

    public function assessmentLogs()
    {
        return $this->hasMany(AssessmentLog::class);
    }
}
