<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\TeacherBurnoutAnalysisSnapshotResource\Pages;
use App\Models\BurnoutAnalysisSnapshot;
use Illuminate\Database\Eloquent\Builder;

class TeacherBurnoutAnalysisSnapshotResource extends BurnoutAnalysisSnapshotResource
{
    protected static ?string $navigationGroup = 'Guru';
    protected static ?string $navigationLabel = 'Analisis Guru';
    protected static ?string $modelLabel = 'Analisis Guru';
    protected static ?string $pluralModelLabel = 'Analisis Guru';
    protected static ?string $navigationIcon = 'heroicon-o-chart-bar-square';
    protected static ?int $navigationSort = 3;
    protected static bool $shouldRegisterNavigation = true;

    public static function getEloquentQuery(): Builder
    {
        return BurnoutAnalysisSnapshot::query()
            ->with('user')
            ->whereHas('user', fn (Builder $query) => $query->role('teacher'));
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) BurnoutAnalysisSnapshot::query()
            ->whereHas('user', fn (Builder $query) => $query->role('teacher'))
            ->count();
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeacherBurnoutAnalysisSnapshots::route('/'),
            'view' => Pages\ViewTeacherBurnoutAnalysisSnapshot::route('/{record}'),
        ];
    }
}
