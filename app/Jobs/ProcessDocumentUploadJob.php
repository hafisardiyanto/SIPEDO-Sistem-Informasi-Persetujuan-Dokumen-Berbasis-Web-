<?php

namespace App\Jobs;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use App\Models\Document;
use Illuminate\Bus\Queueable as BusQueueable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Foundation\Bus\Dispatchable;

class ProcessDocumentUploadJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, BusQueueable, SerializesModels;

    public $projectId;
    public $category;
    public $origName;
    public $ext;
    public $tempPath;

    public function __construct($projectId, $category, $origName, $ext, $tempPath)
    {
        $this->projectId = $projectId;
        $this->category = $category;
        $this->origName = $origName;
        $this->ext = $ext;
        $this->tempPath = $tempPath;
    }

    public function handle(): void
    {
        try {
            // Get contents from local temporary storage
            $fileContents = Storage::disk('local')->get($this->tempPath);

            // Build the final path in public disk
            $filename = uniqid('doc_') . '_' . time() . '.' . $this->ext;
            $finalPath = 'documents/' . $this->category . '/' . $filename;

            // Move it to public storage
            Storage::disk('public')->put($finalPath, $fileContents);

            // Create DB Entry
            Document::create([
                'project_id' => $this->projectId,
                'file_name' => $this->origName,
                'file_path' => $finalPath,
                'file_type' => $this->ext,
                'category' => $this->category
            ]);

            // Clean up temp
            Storage::disk('local')->delete($this->tempPath);

            Log::info("ProcessDocumentUploadJob: Successfully processed $this->origName for Project $this->projectId");

        } catch (\Exception $e) {
            Log::error("ProcessDocumentUploadJob Error: " . $e->getMessage());
        }
    }
}
