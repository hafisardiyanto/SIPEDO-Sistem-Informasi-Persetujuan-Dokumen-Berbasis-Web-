<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AssessmentLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'project_id',
        'assessor_id',
        'status_from',
        'status_to',
        'notes',
        'ip_address',
        'user_agent'
    ];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function assessor()
    {
        return $this->belongsTo(User::class, 'assessor_id');
    }
}
