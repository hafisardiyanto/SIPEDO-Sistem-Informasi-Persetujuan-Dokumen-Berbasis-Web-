<?php

namespace App\Http\Controllers;

use App\Models\Project;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class ExportController extends Controller
{
    public function excel(Request $request)
    {
        $projects = Project::with('user')->latest()->get();

        $csv = "No,Nomor Registrasi,Judul Permohonan,Perusahaan,PIC,Status,Tanggal\n";
        foreach ($projects as $idx => $p) {
            $csv .= ($idx + 1) . ",{$p->project_number},{$p->title},{$p->company_name},{$p->pic_name},{$p->status},{$p->created_at}\n";
        }

        return response($csv)
            ->header('Content-Type', 'text/csv')
            ->header('Content-Disposition', 'attachment; filename="Laporan_Audit_SIPEDO.csv"');
    }

    public function pdf(Request $request)
    {
        $projects = Project::with('user')->latest()->get();

        $html = '
        <h2 style="text-align:center">Laporan Aktivitas Dokumen SIPEDO</h2>
        <table border="1" cellspacing="0" cellpadding="8" width="100%" style="border-collapse: collapse; font-family: sans-serif; font-size: 12px">
            <tr style="background-color: #f1f5f9">
                <th>No</th>
                <th>Project ID</th>
                <th>Pemohon & Entitas</th>
                <th>Judul Proyek</th>
                <th>Status Audit</th>
                <th>Tanggal Masuk</th>
            </tr>';

        foreach ($projects as $idx => $p) {
            $name = $p->user ? $p->user->name : 'Unknown';
            $html .= "
            <tr>
                <td style='text-align:center'>" . ($idx + 1) . "</td>
                <td>{$p->project_number}</td>
                <td>{$name}<br/>({$p->company_name})</td>
                <td>{$p->title}</td>
                <td style='text-align:center'><b>" . strtoupper($p->status) . "</b></td>
                <td>{$p->created_at}</td>
            </tr>";
        }
        $html .= '</table>';

        $pdf = Pdf::loadHTML($html);
        return $pdf->download('Laporan_Audit_SIPEDO.pdf');
    }
}
