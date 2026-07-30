<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use App\Models\Project;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;

class DashboardController extends Controller
{
    public function stats()
    {
        $role = Auth::user()->role;
        $userId = Auth::id();
        $cacheKey = "dashboard_stats_{$role}_{$userId}";

        $stats = Cache::remember($cacheKey, 60, function () use ($role, $userId) {
            $query = Project::query();

            if ($role === 'pemohon') {
                $query->where('user_id', $userId);
            } else if ($role === 'penilai') {
                $query->where('status', '!=', 'draft');
            }

            // High performance SQL aggregation
            $result = collect($query->select(
                DB::raw('count(*) as total'),
                DB::raw("COALESCE(sum(case when status = 'draft' then 1 else 0 end), 0) as draft"),
                DB::raw("COALESCE(sum(case when status = 'submitted' then 1 else 0 end), 0) as submitted"),
                DB::raw("COALESCE(sum(case when status = 'in_review' then 1 else 0 end), 0) as in_review"),
                DB::raw("COALESCE(sum(case when status = 'revision' then 1 else 0 end), 0) as revision"),
                DB::raw("COALESCE(sum(case when status = 'approved' then 1 else 0 end), 0) as approved"),
                DB::raw("COALESCE(sum(case when status = 'rejected' then 1 else 0 end), 0) as rejected")
            )->first())->toArray();

            if ($role === 'penilai') {
                // SLA and Review Average Times
                $avgSec = DB::table('project_reviews')
                    ->where('reviewer_id', $userId)
                    ->join('projects', 'projects.id', '=', 'project_reviews.project_id')
                    ->select(DB::raw('AVG(EXTRACT(EPOCH FROM (project_reviews.created_at - projects.created_at))) as avg_sec'))
                    ->value('avg_sec');

                $result['average_review_time'] = $avgSec ? round($avgSec / 86400, 1) : 0;

                $result['overdue'] = DB::table('projects')
                    ->whereIn('status', ['submitted', 'assigned', 'verification', 'in_review', 'revision'])
                    ->where(function ($q) {
                        $q->where(function ($q2) {
                            $q2->whereNotNull('deadline_date')->where('deadline_date', '<', now());
                        })->orWhere(function ($q2) {
                            $q2->whereNull('deadline_date')->where('created_at', '<', now()->subDays(3));
                        });
                    })
                    ->count();

                $result['today'] = DB::table('project_reviews')
                    ->where('reviewer_id', $userId)
                    ->whereDate('created_at', today())
                    ->count();
            }

            return $result;
        });

        // Add additional grouping for front-end visual charts
        $stats['by_status'] = [
            'draft' => $stats['draft'],
            'submitted' => $stats['submitted'],
            'in_review' => $stats['in_review'],
            'revision' => $stats['revision'],
            'approved' => $stats['approved'],
            'rejected' => $stats['rejected'],
        ];

        return response()->json(['data' => $stats]);
    }
}
