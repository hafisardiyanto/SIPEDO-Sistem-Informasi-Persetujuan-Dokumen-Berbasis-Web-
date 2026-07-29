<?php

namespace App\Http\Controllers;

use App\Models\AssessmentLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Project;
use Illuminate\Support\Facades\DB;

class AssessmentLogController extends Controller
{
    public function index(Request $request)
    {
        if (Auth::user()->role !== 'penilai') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $query = Project::where('status', '!=', 'draft')->with('user', 'documents');

        if ($request->filled('search')) {
            $query->where(function ($q) use ($request) {
                $q->where('title', 'like', '%' . $request->search . '%')
                    ->orWhere('project_number', 'like', '%' . $request->search . '%')
                    ->orWhere('company_name', 'like', '%' . $request->search . '%');
            });
        }
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return response()->json($query->latest()->paginate(10));
    }

    public function evaluate(Request $request, $id)
    {
        if (Auth::user()->role !== 'penilai') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $project = Project::findOrFail($id);

        $request->validate([
            'status' => 'required|in:approved,rejected,revision,in_review,verifikasi_administrasi',
            'notes' => 'nullable|string'
        ]);

        if (in_array($request->status, ['rejected', 'revision']) && empty(trim($request->notes))) {
            return response()->json(['message' => 'Catatan wajib diisi untuk status Revisi atau Ditolak.'], 400);
        }

        DB::beginTransaction();
        try {
            $oldStatus = $project->status;

            $updateData = [
                'status' => $request->status,
                'reviewer_id' => Auth::id(),
                'reviewed_at' => now()
            ];

            if ($request->status === 'approved') {
                $updateData['approved_at'] = now();
            } else if ($request->status === 'rejected') {
                $updateData['rejected_at'] = now();
            } else if ($request->status === 'revision') {
                $updateData['revision_count'] = $project->revision_count + 1;
            }

            $project->update($updateData);

            // Audit Trail: Record IP Address and User Agent
            $log = AssessmentLog::create([
                'project_id' => $project->id,
                'assessor_id' => Auth::id(),
                'status_from' => $oldStatus,
                'status_to' => $request->status,
                'notes' => $request->notes,
                'ip_address' => $request->ip(),
                'user_agent' => $request->header('User-Agent')
            ]);

            DB::commit();
            return response()->json(['message' => 'Project evaluated successfully', 'data' => $log]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }
}
