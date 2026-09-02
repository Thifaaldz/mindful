<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Activity;
use App\Models\BurnoutAnalysisSnapshot;
use App\Models\MindfulnessSession;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class PlatformStatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $totalTeachers = User::role('teacher')->count();
        $totalStudents = User::role('student')->count();
        $totalParents = User::role('parent')->count();
        $activitiesToday = Activity::whereDate('activity_date', today())
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->count();
        $completedToday = Activity::whereDate('activity_date', today())
            ->where('status', Activity::STATUS_COMPLETED)
            ->count();
        $journalReviewsToday = Activity::whereDate('checkout_at', today())
            ->whereNotNull('checkout_suggestion')
            ->count();
        $aiReviewsToday = Activity::whereDate('checkout_at', today())
            ->whereIn('checkout_analysis_source', ['gemini', 'fastapi', 'mock'])
            ->count();
        $latestAnalyses = BurnoutAnalysisSnapshot::where('created_at', '>=', now()->subDays(7))->count();
        $redAnalyses = BurnoutAnalysisSnapshot::where('created_at', '>=', now()->subDays(7))
            ->where('category', 'merah')
            ->count();
        $sessionsThisWeek = MindfulnessSession::where('status', 'completed')
            ->where('started_at', '>=', now()->subDays(7))
            ->count();
        $completionRate = $activitiesToday > 0
            ? round(($completedToday / $activitiesToday) * 100)
            : 0;

        return [
            Stat::make('Guru Terdaftar', $totalTeachers)
                ->icon('heroicon-o-user-group'),
            Stat::make('Siswa Terdaftar', $totalStudents)
                ->icon('heroicon-o-academic-cap'),
            Stat::make('Orang Tua Terhubung', $totalParents)
                ->icon('heroicon-o-heart'),
            Stat::make('Activity Hari Ini', $activitiesToday)
                ->description($completionRate . '% sudah check-out')
                ->icon('heroicon-o-clipboard-document-check')
                ->color($completionRate >= 70 ? 'success' : 'warning'),
            Stat::make('Review Journal Hari Ini', $journalReviewsToday)
                ->description($aiReviewsToday . ' dari AI/service analisis')
                ->icon('heroicon-o-sparkles')
                ->color($aiReviewsToday > 0 ? 'success' : 'gray'),
            Stat::make('Analisis Burnout (7 hari)', $latestAnalyses)
                ->description($redAnalyses . ' status merah')
                ->icon('heroicon-o-chart-bar-square')
                ->color($redAnalyses > 0 ? 'danger' : 'success'),
            Stat::make('Sesi Mindfulness (7 hari)', $sessionsThisWeek)
                ->icon('heroicon-o-clock')
                ->color('success'),
        ];
    }
}
