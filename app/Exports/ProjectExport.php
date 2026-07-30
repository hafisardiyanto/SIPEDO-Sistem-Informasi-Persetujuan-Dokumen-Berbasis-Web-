<?php

namespace App\Exports;

use App\Models\Project;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class ProjectExport implements FromCollection, WithHeadings, WithMapping
{
    public function collection()
    {
        return Project::with('user')->get();
    }

    public function map($project): array
    {
        return [
            $project->project_number,
            $project->title,
            $project->user->name ?? 'Unknown',
            $project->company_name,
            $project->doc_type,
            $project->status,
            $project->created_at->format('d/m/Y H:i:s')
        ];
    }

    public function headings(): array
    {
        return [
            'Nomor Registrasi',
            'Judul Dokumen Proyek',
            'Nama Pemohon',
            'Perusahaan / Entitas',
            'Bentuk Surat (Tipe)',
            'Status Akhir',
            'Tanggal Masuk Sistem'
        ];
    }
}
