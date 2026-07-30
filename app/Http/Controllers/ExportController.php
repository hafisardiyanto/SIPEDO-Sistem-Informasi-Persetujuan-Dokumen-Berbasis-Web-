<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;
use App\Exports\ProjectExport;
use App\Models\Project;
use Barryvdh\DomPDF\Facade\Pdf;

class ExportController extends Controller
{
    public function excel()
    {
        return Excel::download(new ProjectExport, 'Laporan_Rekap_SIPEDO.xlsx');
    }

    public function pdf()
    {
        $projects = Project::with('user')->latest()->get();

        $pdf = Pdf::loadView('exports.projects_pdf', compact('projects'));
        // For Enterprise apps we use paper size & orientation
        $pdf->setPaper('A4', 'landscape');

        return $pdf->download('Laporan_Penuh_SIPEDO.pdf');
    }
}
