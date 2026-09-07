<?php

namespace App\Filament\School\Widgets;

use App\Models\Activity;
use App\Models\SchoolClass;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class SchoolStatsOverview extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        $schoolId = auth()->user()?->school_id;

        $teacherActivitiesToday = Activity::query()
            ->whereDate('activity_date', now())
            ->whereHas('owner', fn ($ownerQuery) => $ownerQuery
                ->role('teacher')
                ->where('school_id', $schoolId))
            ->count();

        $studentActivitiesToday = Activity::query()
            ->whereDate('activity_date', now())
            ->whereHas('owner', fn ($ownerQuery) => $ownerQuery
                ->role('student')
                ->where('school_id', $schoolId))
            ->count();

        return [
            Stat::make('Kelas Aktif', SchoolClass::query()
                ->where('school_id', $schoolId)
                ->where('is_active', true)
                ->count())
                ->icon('heroicon-m-academic-cap'),
            Stat::make('Guru', User::query()
                ->role('teacher')
                ->where('school_id', $schoolId)
                ->where('approval_status', 'approved')
                ->count())
                ->icon('heroicon-m-user-group'),
            Stat::make('Murid', User::query()
                ->role('student')
                ->where('school_id', $schoolId)
                ->where('approval_status', 'approved')
                ->count())
                ->icon('heroicon-m-users'),
            Stat::make('Parent Management', User::query()
                ->role('parent')
                ->where(function ($query) use ($schoolId) {
                    $query->where('school_id', $schoolId)
                        ->orWhereHas('parentChildren', fn ($childQuery) => $childQuery->where('school_id', $schoolId));
                })
                ->count())
                ->icon('heroicon-m-heart'),
            Stat::make('Pending Guru', User::query()
                ->where('school_id', $schoolId)
                ->where('approval_status', 'pending')
                ->role('teacher')
                ->count())
                ->color('warning')
                ->icon('heroicon-m-clock'),
            Stat::make('Pending Murid', User::query()
                ->where('school_id', $schoolId)
                ->where('approval_status', 'pending')
                ->role('student')
                ->count())
                ->color('warning')
                ->icon('heroicon-m-clock'),
            Stat::make('Activity Guru Hari Ini', $teacherActivitiesToday)
                ->icon('heroicon-m-calendar-days'),
            Stat::make('Activity Murid Hari Ini', $studentActivitiesToday)
                ->icon('heroicon-m-calendar-days'),
        ];
    }
}
