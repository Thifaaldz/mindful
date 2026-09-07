<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\StudentActivityResource\Pages;
use App\Models\Activity;
use Illuminate\Database\Eloquent\Builder;

class StudentActivityResource extends SchoolActivityResource
{
    protected static ?string $navigationGroup = 'Murid';
    protected static ?string $navigationLabel = 'Activity Murid';
    protected static ?string $modelLabel = 'Activity Murid';
    protected static ?string $pluralModelLabel = 'Activity Murid';
    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?int $navigationSort = 3;
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
            ->whereHas('owner', fn (Builder $query) => $query->role('student'));
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStudentActivities::route('/'),
            'view' => Pages\ViewStudentActivity::route('/{record}'),
        ];
    }
}
