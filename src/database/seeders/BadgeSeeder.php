<?php

namespace Database\Seeders;

use App\Models\Badge;
use Illuminate\Database\Seeder;

class BadgeSeeder extends Seeder
{
    public function run(): void
    {
        $badges = [
            ['code' => 'streak_10', 'name' => '10 Hari Berturut-turut', 'description' => 'Konsisten berlatih mindfulness selama 10 hari berturut-turut.'],
            ['code' => 'calmness_up_20', 'name' => 'Peningkatan 20%', 'description' => 'Skor ketenangan meningkat 20% dibanding minggu sebelumnya.'],
            ['code' => 'first_session', 'name' => 'Sesi Pertama', 'description' => 'Menyelesaikan sesi mindfulness pertama.'],
        ];

        foreach ($badges as $badge) {
            Badge::firstOrCreate(['code' => $badge['code']], $badge);
        }
    }
}
