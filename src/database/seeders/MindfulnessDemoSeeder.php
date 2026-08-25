<?php

namespace Database\Seeders;

use App\Models\Badge;
use App\Models\MindfulnessSession;
use App\Models\User;
use Illuminate\Database\Seeder;

class MindfulnessDemoSeeder extends Seeder
{
    public function run(): void
    {
        $demoSessions = [
            'guru@mindfuledu.test' => [
                [9, '07:00', 480, 4, 4, 6, 'Mulai membangun kebiasaan jeda napas sebelum kelas.'],
                [8, '12:50', 540, 3, 4, 7, 'Lebih tenang setelah jadwal mengajar padat.'],
                [7, '07:05', 600, 3, 5, 7, 'Latihan membantu menjaga fokus pagi.'],
                [6, '07:10', 540, 4, 4, 6, 'Lebih siap memulai kelas setelah jeda napas.'],
                [5, '13:05', 600, 3, 5, 7, 'Pikiran lebih ringan setelah jam pelajaran padat.'],
                [4, '07:25', 480, 2, 5, 8, 'Fokus terasa lebih stabil sebelum mengajar.'],
                [3, '12:40', 720, 5, 3, 6, 'Masih terdistraksi, tetapi lebih cepat kembali ke napas.'],
                [2, '07:15', 600, 2, 6, 8, 'Sesi terasa membantu menjaga tempo bicara.'],
                [1, '14:20', 540, 1, 6, 9, 'Lebih tenang menghadapi kelas terakhir.'],
                [0, '07:30', 600, 2, 5, 8, 'Hari ini terasa lebih jernih dan terarah.'],
            ],
            'guru.bima@mindfuledu.test' => [
                [4, '06:55', 480, 3, 4, 6, 'Latihan singkat membantu transisi sebelum kelas.'],
                [2, '13:15', 540, 2, 5, 7, 'Lebih sabar saat menutup pembelajaran.'],
                [0, '07:05', 600, 2, 5, 8, 'Fokus pagi cukup baik.'],
            ],
            'guru.rani@mindfuledu.test' => [
                [5, '07:00', 600, 4, 3, 6, 'Butuh waktu untuk menenangkan pikiran.'],
                [3, '12:30', 480, 3, 4, 7, 'Sesi terasa membantu setelah observasi siswa.'],
                [1, '07:20', 540, 2, 5, 8, 'Lebih siap menyapa siswa.'],
                [0, '14:00', 600, 2, 6, 8, 'Menutup hari dengan lebih tenang.'],
            ],
        ];

        foreach ($demoSessions as $email => $sessions) {
            $teacher = User::where('email', $email)->first();

            if (! $teacher) {
                continue;
            }

            $teacher->mindfulnessSessions()
                ->where('status', 'in_progress')
                ->delete();

            foreach ($sessions as [$daysAgo, $time, $duration, $distraction, $before, $after, $reflection]) {
                $startedAt = now()
                    ->subDays($daysAgo)
                    ->setTimeFromTimeString($time);

                MindfulnessSession::updateOrCreate(
                    [
                        'user_id' => $teacher->id,
                        'started_at' => $startedAt,
                    ],
                    [
                        'completed_at' => $startedAt->copy()->addSeconds($duration),
                        'duration_seconds' => $duration,
                        'distraction_score' => $distraction,
                        'calmness_before' => $before,
                        'calmness_after' => $after,
                        'reflection' => $reflection,
                        'body_note' => $reflection,
                        'helpful_note' => 'Latihan napas perlahan dan jeda singkat membantu saya kembali hadir.',
                        'logbook_answers' => [
                            'mood' => min(5, max(1, $after - 2)),
                            'energy' => min(5, max(1, $after - 3)),
                            'focus' => min(5, max(1, $after - 2)),
                            'teaching_readiness' => min(5, max(1, $after - 2)),
                        ],
                        'status' => 'completed',
                    ]
                );
            }

            $this->awardBadges($teacher);
        }
    }

    private function awardBadges(User $teacher): void
    {
        $completedCount = $teacher->mindfulnessSessions()
            ->where('status', 'completed')
            ->count();

        $avgBefore = $teacher->mindfulnessSessions()
            ->where('status', 'completed')
            ->avg('calmness_before');

        $avgAfter = $teacher->mindfulnessSessions()
            ->where('status', 'completed')
            ->avg('calmness_after');

        $badges = [];

        if ($completedCount >= 1) {
            $badges[] = 'first_session';
        }

        if ($completedCount >= 10) {
            $badges[] = 'streak_10';
        }

        if ($avgBefore && $avgAfter && (($avgAfter - $avgBefore) / $avgBefore) >= 0.2) {
            $badges[] = 'calmness_up_20';
        }

        foreach ($badges as $code) {
            $badge = Badge::where('code', $code)->first();

            if (! $badge) {
                continue;
            }

            $teacher->badges()->syncWithoutDetaching([
                $badge->id => ['earned_at' => now()],
            ]);
        }
    }
}
