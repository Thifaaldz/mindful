<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\StudentBurnoutAnalysisSnapshotResource\Pages;
use App\Models\BurnoutAnalysisSnapshot;
use Illuminate\Database\Eloquent\Builder;

class StudentBurnoutAnalysisSnapshotResource extends BurnoutAnalysisSnapshotResource
{
    protected static ?string $navigationGroup = 'Murid';
    protected static ?string $navigationLabel = 'Analisis Murid';
    protected static ?string $modelLabel = 'Analisis Murid';
    protected static ?string $pluralModelLabel = 'Analisis Murid';
    protected static ?string $navigationIcon = 'heroicon-o-chart-bar-square';
    protected static ?int $navigationSort = 3;
    protected static bool $shouldRegisterNavigation = true;

    public static function getEloquentQuery(): Builder
    {
        return BurnoutAnalysisSnapshot::query()
            ->with('user')
            ->whereHas('user', fn (Builder $query) => $query->role('student'));
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) BurnoutAnalysisSnapshot::query()
            ->whereHas('user', fn (Builder $query) => $query->role('student'))
            ->count();
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStudentBurnoutAnalysisSnapshots::route('/'),
            'view' => Pages\ViewStudentBurnoutAnalysisSnapshot::route('/{record}'),
        ];
    }
}
