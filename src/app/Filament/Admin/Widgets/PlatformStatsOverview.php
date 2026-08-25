<?php

namespace App\Filament\Admin\Widgets;

use App\Models\MindfulnessSession;
use App\Models\StudentObservation;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class PlatformStatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $totalTeachers = User::role('teacher')->count();
        $totalStudents = User::role('student')->count();
        $sessionsThisWeek = MindfulnessSession::where('status', 'completed')
            ->where('started_at', '>=', now()->subDays(7))
            ->count();
        $flagged = StudentObservation::whereIn('status', ['kuning', 'merah'])
            ->where('observed_on', '>=', now()->subDays(7))
            ->count();

        return [
            Stat::make('Guru Terdaftar', $totalTeachers)
                ->icon('heroicon-o-user-group'),
            Stat::make('Siswa Terdaftar', $totalStudents)
                ->icon('heroicon-o-academic-cap'),
            Stat::make('Sesi Mindfulness (7 hari)', $sessionsThisWeek)
                ->icon('heroicon-o-clock')
                ->color('success'),
            Stat::make('Siswa Perlu Perhatian (7 hari)', $flagged)
                ->icon('heroicon-o-exclamation-triangle')
                ->color($flagged > 0 ? 'danger' : 'success'),
        ];
    }
}
