<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use App\Models\Project;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function stats()
    {
        $role = Auth::user()->role;
        $query = Project::query();

        if ($role === 'pemohon') {
            $query->where('user_id', Auth::id());
        } else if ($role === 'penilai') {
            $query->where('status', '!=', 'draft');
        } else {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // High performance SQL aggregation (PostgreSQL Requires SINGLE Quote for Strings)
        $stats = collect($query->select(
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
                ->where('reviewer_id', Auth::id())
                ->join('projects', 'projects.id', '=', 'project_reviews.project_id')
                ->select(DB::raw('AVG(EXTRACT(EPOCH FROM (project_reviews.created_at - projects.created_at))) as avg_sec'))
                ->value('avg_sec');

            $stats['average_review_time'] = $avgSec ? round($avgSec / 86400, 1) : 0;

            $stats['overdue'] = DB::table('project_assignments')
                ->where('assessor_id', Auth::id())
                ->join('projects', 'projects.id', '=', 'project_assignments.project_id')
                ->whereIn('projects.status', ['assigned', 'verification', 'in_review'])
                ->where('project_assignments.created_at', '<', now()->subDays(3))
                ->count();

            $stats['today'] = DB::table('project_reviews')
                ->where('reviewer_id', Auth::id())
                ->whereDate('created_at', today())
                ->count();
        }

        return response()->json(['data' => $stats]);
    }
}
