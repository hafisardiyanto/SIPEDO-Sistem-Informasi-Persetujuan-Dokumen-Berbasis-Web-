<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create Pemohon
        User::create([
            'name' => 'Pemohon 1',
            'email' => 'pemohon@example.com',
            'password' => Hash::make('password'),
            'role' => 'pemohon'
        ]);

        // Create Penilai
        User::create([
            'name' => 'Penilai 1',
            'email' => 'penilai@example.com',
            'password' => Hash::make('password'),
            'role' => 'penilai'
        ]);
    }
}
