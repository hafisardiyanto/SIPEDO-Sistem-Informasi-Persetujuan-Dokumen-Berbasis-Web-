<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Project;
use App\Models\Document;

class ProjectController extends Controller
{
    public function index()
    {
        $projects = Auth::user()->projects()->with('documents')->latest()->get();
        return response()->json(['data' => $projects]);
    }

    public function store(Request $request)
    {
        if (Auth::user()->role !== 'pemohon') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'document' => 'required|file|mimes:pdf,doc,docx|max:10240',
        ]);

        $project = Auth::user()->projects()->create([
            'title' => $request->title,
            'description' => $request->description,
            'status' => 'draft',
        ]);

        if ($request->hasFile('document')) {
            $file = $request->file('document');
            $path = $file->store('documents', 'public');
            $project->documents()->create([
                'file_name' => $file->getClientOriginalName(),
                'file_path' => $path,
                'file_type' => $file->getClientOriginalExtension(),
            ]);
        }

        return response()->json(['message' => 'Project created', 'data' => $project->load('documents')], 201);
    }

    public function show(Project $project)
    {
        if ($project->user_id !== Auth::id())
            return response()->json(['message' => 'Forbidden'], 403);

        return response()->json(['data' => $project->load('documents', 'assessmentLogs.assessor')]);
    }

    public function update(Request $request, Project $project)
    {
        if ($project->user_id !== Auth::id() || $project->status !== 'draft') {
            return response()->json(['message' => 'Forbidden or not in draft'], 403);
        }

        $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'document' => 'nullable|file|mimes:pdf,doc,docx|max:10240',
        ]);

        $project->update($request->only('title', 'description'));

        if ($request->hasFile('document')) {
            $project->documents()->delete(); // Replace old for MVP

            $file = $request->file('document');
            $path = $file->store('documents', 'public');
            $project->documents()->create([
                'file_name' => $file->getClientOriginalName(),
                'file_path' => $path,
                'file_type' => $file->getClientOriginalExtension(),
            ]);
        }

        return response()->json(['message' => 'Project updated', 'data' => $project->load('documents')]);
    }

    public function submit(Project $project)
    {
        if ($project->user_id !== Auth::id()) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        if (!in_array($project->status, ['draft', 'revision'])) {
            return response()->json(['message' => 'Project cannot be submitted'], 400);
        }

        $project->update(['status' => 'submitted']);
        return response()->json(['message' => 'Project submitted successfully']);
    }

    public function history(Project $project)
    {
        if ($project->user_id !== Auth::id())
            return response()->json(['message' => 'Forbidden'], 403);
        return response()->json(['data' => $project->assessmentLogs()->with('assessor')->latest()->get()]);
    }
}
