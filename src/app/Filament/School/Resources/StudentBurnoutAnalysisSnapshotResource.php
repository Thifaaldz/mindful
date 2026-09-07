<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\StudentBurnoutAnalysisSnapshotResource\Pages;
use App\Models\BurnoutAnalysisSnapshot;
use Illuminate\Database\Eloquent\Builder;

class StudentBurnoutAnalysisSnapshotResource extends SchoolBurnoutAnalysisSnapshotResource
{
    protected static ?string $navigationGroup = 'Murid';
    protected static ?string $navigationLabel = 'Analisis Murid';
    protected static ?string $modelLabel = 'Analisis Murid';
    protected static ?string $pluralModelLabel = 'Analisis Murid';
    protected static ?string $navigationIcon = 'heroicon-o-chart-bar-square';
    protected static ?int $navigationSort = 4;
    protected static bool $shouldRegisterNavigation = true;

    public static function getEloquentQuery(): Builder
    {
        return BurnoutAnalysisSnapshot::query()
            ->with('user')
            ->whereHas('user', fn (Builder $query) => $query
                ->where('school_id', static::schoolId())
                ->role('student'));
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStudentBurnoutAnalysisSnapshots::route('/'),
            'view' => Pages\ViewStudentBurnoutAnalysisSnapshot::route('/{record}'),
        ];
    }
}
