<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Schedule;
use App\Models\User;
use App\Services\BurnoutAnalysisService;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('reminders:send', function () {
    $now = now();

    User::where('reminder_enabled', true)
        ->where('reminder_channel', 'email')
        ->whereNotNull('reminder_time')
        ->chunkById(100, function ($users) use ($now) {
            foreach ($users as $user) {
                $timezone = $user->reminder_timezone ?: config('app.timezone');
                $localNow = $now->copy()->timezone($timezone);
                $reminderTime = substr((string) $user->reminder_time, 0, 5);

                if ($localNow->format('H:i') !== $reminderTime) {
                    continue;
                }

                if ($user->last_reminder_sent_at?->timezone($timezone)->isSameDay($localNow)) {
                    continue;
                }

                Mail::raw(
                    "Saatnya mengambil jeda mindful singkat hari ini.\n\nBuka MindfulEdu dan mulai sesi 5-10 menit.",
                    fn ($message) => $message
                        ->to($user->email)
                        ->subject('Pengingat Latihan Mindfulness')
                );

                $user->forceFill(['last_reminder_sent_at' => $now])->save();
            }
        });

    $this->info('Reminder email diproses.');
})->purpose('Send daily email mindfulness reminders');

Schedule::command('reminders:send')->everyMinute();

Artisan::command('burnout:weekly-analysis', function (BurnoutAnalysisService $analysisService) {
    [$periodStart, $periodEnd] = $analysisService->periodRange('weekly', now()->subWeek());

    User::role(['teacher', 'student'])
        ->chunkById(100, function ($users) use ($analysisService, $periodStart, $periodEnd) {
            foreach ($users as $user) {
                $alreadyAnalyzed = $user->burnoutAnalysisSnapshots()
                    ->where('source', 'auto_weekly')
                    ->where('period_type', 'weekly')
                    ->whereDate('period_start', $periodStart)
                    ->whereDate('period_end', $periodEnd)
                    ->exists();

                if ($alreadyAnalyzed) {
                    continue;
                }

                $analysisService->analyze($user, 'weekly', $periodStart, 'auto_weekly');
            }
        });

    $this->info('Weekly burnout analysis diproses.');
})->purpose('Run automatic weekly activity-ledger burnout analysis');

Schedule::command('burnout:weekly-analysis')->weeklyOn(1, '06:00');
