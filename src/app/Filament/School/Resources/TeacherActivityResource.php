<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\TeacherActivityResource\Pages;
use App\Models\Activity;
use Illuminate\Database\Eloquent\Builder;

class TeacherActivityResource extends SchoolActivityResource
{
    protected static ?string $navigationGroup = 'Guru';
    protected static ?string $navigationLabel = 'Activity Guru';
    protected static ?string $modelLabel = 'Activity Guru';
    protected static ?string $pluralModelLabel = 'Activity Guru';
    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?int $navigationSort = 2;
    protected static bool $shouldRegisterNavigation = true;

    public static function getEloquentQuery(): Builder
    {
        $schoolId = static::schoolId();

        return Activity::query()
            ->with(['owner', 'schoolClass'])
            ->where(function (Builder $query) use ($schoolId) {
                $query->where('school_id', $schoolId)
                    ->orWhereHas('owner', fn (Builder $ownerQuery) => $ownerQuery->where('school_id', $schoolId));
            })
            ->whereHas('owner', fn (Builder $query) => $query->role('teacher'));
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeacherActivities::route('/'),
            'view' => Pages\ViewTeacherActivity::route('/{record}'),
        ];
    }
}
