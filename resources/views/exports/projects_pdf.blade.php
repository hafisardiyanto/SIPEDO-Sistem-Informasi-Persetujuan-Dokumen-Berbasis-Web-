<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>Laporan Proyek SIPEDO</title>
    <style>
        body {
            font-family: sans-serif;
            font-size: 12px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th,
        td {
            border: 1px solid #333;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #3b82f6;
            color: white;
        }

        h1 {
            text-align: center;
            color: #1e3a8a;
        }

        .text-center {
            text-align: center;
        }
    </style>
</head>

<body>
    <h1>Laporan Rekapitulasi Proyek SIPEDO</h1>
    <p>Dicetak Pada Tanggal: {{ date('d F Y') }}</p>

    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Nomor Registrasi</th>
                <th>Judul Proyek</th>
                <th>Perusahaan</th>
                <th>Tipe Surat</th>
                <th>Pemohon</th>
                <th>Status Final</th>
            </tr>
        </thead>
        <tbody>
            @foreach($projects as $i => $proj)
                <tr>
                    <td class="text-center">{{ $i + 1 }}</td>
                    <td>{{ $proj->project_number }}</td>
                    <td>{{ $proj->title }}</td>
                    <td>{{ $proj->company_name }}</td>
                    <td>{{ $proj->doc_type }}</td>
                    <td>{{ optional($proj->user)->name }}</td>
                    <td class="text-center">{{ strtoupper($proj->status) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
</body>

</html>