<?php

namespace App\Http\Controllers;

use App\Models\AssessmentLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Project;

class AssessmentLogController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        if (Auth::user()->role !== 'penilai') {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        // Penilai see all projects that are not draft
        $projects = Project::where('status', '!=', 'draft')->with('user', 'documents')->latest()->get();
        return response()->json(['data' => $projects]);
    }

    /**
     * Evaluate a project.
     */
    public function evaluate(Request $request, Project $project)
    {
        if (Auth::user()->role !== 'penilai') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $request->validate([
            'status' => 'required|in:approved,rejected,revision,in_review',
            'notes' => 'nullable|string'
        ]);

        $oldStatus = $project->status;
        $project->update(['status' => $request->status]);

        $log = AssessmentLog::create([
            'project_id' => $project->id,
            'assessor_id' => Auth::id(),
            'status_from' => $oldStatus,
            'status_to' => $request->status,
            'notes' => $request->notes,
        ]);

        return response()->json(['message' => 'Project evaluated successfully', 'data' => $log]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(AssessmentLog $assessmentLog)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, AssessmentLog $assessmentLog)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(AssessmentLog $assessmentLog)
    {
        //
    }
}
