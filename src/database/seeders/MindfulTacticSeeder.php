<?php

namespace Database\Seeders;

use App\Models\MindfulTactic;
use Illuminate\Database\Seeder;

class MindfulTacticSeeder extends Seeder
{
    public function run(): void
    {
        $tactics = [
            [
                'title' => 'Single-Tasking',
                'category' => 'single_tasking',
                'description' => 'Fokus pada satu tugas mengajar dalam satu waktu untuk mengurangi beban kognitif dan meningkatkan kualitas kehadiran di kelas.',
                'sort_order' => 1,
            ],
            [
                'title' => 'Tempo Stabil',
                'category' => 'tempo_stabil',
                'description' => 'Jaga tempo bicara dan gerakan tetap stabil agar suasana kelas terasa lebih tenang dan terkendali.',
                'sort_order' => 2,
            ],
            [
                'title' => 'Jeda Sengaja',
                'category' => 'jeda_sengaja',
                'description' => 'Ambil jeda singkat secara sengaja di antara penjelasan untuk memberi ruang berpikir bagi guru dan siswa.',
                'sort_order' => 3,
            ],
            [
                'title' => 'Cek Pemahaman',
                'category' => 'cek_pemahaman',
                'description' => 'Luangkan waktu untuk mengecek pemahaman siswa secara mindful sebelum melanjutkan materi baru.',
                'sort_order' => 4,
            ],
        ];

        foreach ($tactics as $tactic) {
            MindfulTactic::firstOrCreate(['title' => $tactic['title']], $tactic);
        }
    }
}
