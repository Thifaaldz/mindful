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
        $teacherActivitiesToday = Activity::whereDate('activity_date', today())
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->whereHas('owner', fn ($query) => $query->role('teacher'))
            ->count();
        $studentActivitiesToday = Activity::whereDate('activity_date', today())
            ->where('status', '!=', Activity::STATUS_CANCELLED)
            ->whereHas('owner', fn ($query) => $query->role('student'))
            ->count();
        $activitiesToday = $teacherActivitiesToday + $studentActivitiesToday;
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
        $teacherAnalyses = BurnoutAnalysisSnapshot::where('created_at', '>=', now()->subDays(7))
            ->whereHas('user', fn ($query) => $query->role('teacher'))
            ->count();
        $studentAnalyses = BurnoutAnalysisSnapshot::where('created_at', '>=', now()->subDays(7))
            ->whereHas('user', fn ($query) => $query->role('student'))
            ->count();
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
            Stat::make('Activity Guru Hari Ini', $teacherActivitiesToday)
                ->description('Dipisah dari activity murid')
                ->icon('heroicon-o-calendar-days')
                ->color('success'),
            Stat::make('Activity Murid Hari Ini', $studentActivitiesToday)
                ->description($completionRate . '% semua activity sudah check-out')
                ->icon('heroicon-o-clipboard-document-check')
                ->color($completionRate >= 70 ? 'success' : 'warning'),
            Stat::make('Analisa Jurnal Hari Ini', $journalReviewsToday)
                ->description($aiReviewsToday . ' analisa otomatis')
                ->icon('heroicon-o-sparkles')
                ->color($aiReviewsToday > 0 ? 'success' : 'gray'),
            Stat::make('Analisis Guru (7 hari)', $teacherAnalyses)
                ->description($redAnalyses . ' status merah total')
                ->icon('heroicon-o-chart-bar-square')
                ->color($redAnalyses > 0 ? 'danger' : 'success'),
            Stat::make('Analisis Murid (7 hari)', $studentAnalyses)
                ->description($latestAnalyses . ' analisis total')
                ->icon('heroicon-o-chart-bar-square')
                ->color($redAnalyses > 0 ? 'danger' : 'success'),
            Stat::make('Sesi Mindfulness (7 hari)', $sessionsThisWeek)
                ->icon('heroicon-o-clock')
                ->color('success'),
        ];
    }
}
