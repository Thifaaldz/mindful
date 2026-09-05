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
            Stat::make('Pending Approval', User::query()
                ->where('school_id', $schoolId)
                ->where('approval_status', 'pending')
                ->whereHas('roles', fn ($query) => $query->whereIn('name', ['teacher', 'student']))
                ->count())
                ->color('warning')
                ->icon('heroicon-m-clock'),
            Stat::make('Activity Hari Ini', Activity::query()
                ->whereDate('activity_date', now())
                ->where(function ($query) use ($schoolId) {
                    $query->where('school_id', $schoolId)
                        ->orWhereHas('owner', fn ($ownerQuery) => $ownerQuery->where('school_id', $schoolId));
                })
                ->count())
                ->icon('heroicon-m-calendar-days'),
        ];
    }
}
