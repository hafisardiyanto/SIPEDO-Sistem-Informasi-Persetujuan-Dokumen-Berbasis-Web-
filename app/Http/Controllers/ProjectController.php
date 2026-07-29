<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Project;
use App\Models\Document;
use Illuminate\Support\Facades\DB;

class ProjectController extends Controller
{
    public function index(Request $request)
    {
        $query = Auth::user()->projects()->with('documents');

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

        // Return lengthAwarePaginator object
        return response()->json($query->latest()->paginate(10));
    }

    public function store(Request $request)
    {
        if (Auth::user()->role !== 'pemohon') {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'company_name' => 'nullable|string|max:255',
            'pic_name' => 'nullable|string|max:255',
            'phone' => 'nullable|string',
            'email_pic' => 'nullable|email',
            'doc_type' => 'nullable|string',
            'additional_notes' => 'nullable|string',
            'document_utama' => 'nullable|file|mimes:pdf,doc,docx|max:20480', // 20MB Check
            'document_lampiran' => 'nullable|file|mimes:pdf,doc,docx,zip,rar|max:20480',
            'document_pengantar' => 'nullable|file|mimes:pdf,doc,docx|max:20480',
            'document_pendukung' => 'nullable|file|mimes:pdf,doc,docx,jpg,png|max:20480',
        ]);

        DB::beginTransaction();
        try {
            $project = Auth::user()->projects()->create([
                'title' => $request->title,
                'description' => $request->description,
                'company_name' => $request->company_name,
                'pic_name' => $request->pic_name,
                'phone' => $request->phone,
                'email_pic' => $request->email_pic,
                'doc_type' => $request->doc_type,
                'additional_notes' => $request->additional_notes,
                'status' => 'draft',
            ]);

            // Save multi-files dynamically based on category
            $categories = ['utama' => 'document_utama', 'lampiran' => 'document_lampiran', 'pengantar' => 'document_pengantar', 'pendukung' => 'document_pendukung'];
            foreach ($categories as $cat => $fileKey) {
                if ($request->hasFile($fileKey)) {
                    $file = $request->file($fileKey);
                    $path = $file->store('documents/' . $cat, 'public');
                    $project->documents()->create([
                        'file_name' => $file->getClientOriginalName(),
                        'file_path' => $path,
                        'file_type' => $file->getClientOriginalExtension(),
                        'category' => $cat
                    ]);
                }
            }
            DB::commit();
            return response()->json(['message' => 'Project created', 'data' => $project->load('documents')], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function show($id)
    {
        $project = Project::with('documents', 'assessmentLogs.assessor')->findOrFail($id);

        if ($project->user_id !== Auth::id())
            return response()->json(['message' => 'Forbidden'], 403);

        return response()->json(['data' => $project]);
    }

    public function update(Request $request, $id)
    {
        $project = Project::findOrFail($id);

        if ($project->user_id !== Auth::id() || $project->status !== 'draft') {
            return response()->json(['message' => 'Forbidden or not in draft'], 403);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'company_name' => 'nullable|string|max:255',
            'pic_name' => 'nullable|string|max:255',
            'phone' => 'nullable|string',
            'email_pic' => 'nullable|email',
            'doc_type' => 'nullable|string',
            'additional_notes' => 'nullable|string',
            'document_utama' => 'nullable|file|mimes:pdf,doc,docx|max:20480',
            'document_lampiran' => 'nullable|file|mimes:pdf,doc,docx,zip,rar|max:20480',
            'document_pengantar' => 'nullable|file|mimes:pdf,doc,docx|max:20480',
            'document_pendukung' => 'nullable|file|mimes:pdf,doc,docx,jpg,png|max:20480',
        ]);

        DB::beginTransaction();
        try {
            $project->update($request->only(
                'title',
                'description',
                'company_name',
                'pic_name',
                'phone',
                'email_pic',
                'doc_type',
                'additional_notes'
            ));

            $categories = ['utama' => 'document_utama', 'lampiran' => 'document_lampiran', 'pengantar' => 'document_pengantar', 'pendukung' => 'document_pendukung'];
            foreach ($categories as $cat => $fileKey) {
                if ($request->hasFile($fileKey)) {
                    // Delete old file of same category
                    $project->documents()->where('category', $cat)->delete();

                    $file = $request->file($fileKey);
                    $path = $file->store('documents/' . $cat, 'public');
                    $project->documents()->create([
                        'file_name' => $file->getClientOriginalName(),
                        'file_path' => $path,
                        'file_type' => $file->getClientOriginalExtension(),
                        'category' => $cat
                    ]);
                }
            }
            DB::commit();
            return response()->json(['message' => 'Project updated', 'data' => $project->load('documents')]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function submit($id)
    {
        $project = Project::findOrFail($id);
        if ($project->user_id !== Auth::id()) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        if (!in_array($project->status, ['draft', 'revision'])) {
            return response()->json(['message' => 'Project cannot be submitted'], 400);
        }

        $project->update([
            'status' => 'submitted',
            'submitted_at' => now(),
        ]);
        return response()->json(['message' => 'Project submitted successfully']);
    }

    public function history($id)
    {
        $project = Project::findOrFail($id);
        if ($project->user_id !== Auth::id())
            return response()->json(['message' => 'Forbidden'], 403);
        return response()->json(['data' => $project->assessmentLogs()->with('assessor')->latest()->get()]);
    }

    public function destroy($id)
    {
        $project = Project::findOrFail($id);

        // RBAC API Policy: Admin can delete anything, Pemohon can only delete their own drafts
        $user = Auth::user();
        if ($user->role !== 'admin') {
            if ($project->user_id !== $user->id) {
                return response()->json(['message' => 'Forbidden: You do not own this document'], 403);
            }
            if ($project->status !== 'draft') {
                return response()->json(['message' => 'Cannot delete document that is already submitted'], 400);
            }
        }

        $project->delete(); // This triggers SoftDelete because of our Phase 1 updates

        // Let's log it safely with Spatie
        try {
            activity()->causedBy($user)->performedOn($project)->log('Project soft deleted');
        } catch (\Exception $e) {
        }

        return response()->json(['message' => 'Project moved to trash successfully']);
    }

    public function trash()
    {
        $projects = \App\Models\Project::where('user_id', \Illuminate\Support\Facades\Auth::id())->onlyTrashed()->paginate(10);
        return response()->json($projects);
    }

    public function restore($id)
    {
        $project = \App\Models\Project::onlyTrashed()->where('user_id', \Illuminate\Support\Facades\Auth::id())->findOrFail($id);
        $project->restore();

        try {
            activity()->causedBy(\Illuminate\Support\Facades\Auth::user())->performedOn($project)->log('Project restored from trash');
        } catch (\Exception $e) {
        }

        return response()->json(['message' => 'Project restored successfully']);
    }
}
