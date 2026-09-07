<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\StudentActivityResource\Pages;
use App\Models\Activity;
use Illuminate\Database\Eloquent\Builder;

class StudentActivityResource extends TeacherActivityResource
{
    protected static ?string $navigationGroup = 'Murid';
    protected static ?string $navigationLabel = 'Activity Murid';
    protected static ?string $modelLabel = 'Activity Murid';
    protected static ?string $pluralModelLabel = 'Activity Murid';
    protected static ?string $navigationIcon = 'heroicon-o-calendar-days';
    protected static ?int $navigationSort = 2;

    public static function getEloquentQuery(): Builder
    {
        return Activity::query()
            ->with(['owner', 'schoolModel', 'schoolClass'])
            ->whereHas('owner', fn (Builder $query) => $query->role('student'));
    }

    protected static function ownerLabel(): string
    {
        return 'Murid';
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStudentActivities::route('/'),
            'view' => Pages\ViewStudentActivity::route('/{record}'),
        ];
    }
}
