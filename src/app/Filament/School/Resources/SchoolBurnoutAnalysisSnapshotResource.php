<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\SchoolBurnoutAnalysisSnapshotResource\Pages;
use App\Models\BurnoutAnalysisSnapshot;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SchoolBurnoutAnalysisSnapshotResource extends Resource
{
    use BelongsToSchoolPanel;

    protected static ?string $model = BurnoutAnalysisSnapshot::class;
    protected static ?string $navigationGroup = 'Monitoring';
    protected static ?string $navigationLabel = 'Burnout Analysis';
    protected static ?string $modelLabel = 'Burnout Analysis';
    protected static ?string $pluralModelLabel = 'Burnout Analysis';
    protected static ?string $navigationIcon = 'heroicon-o-chart-bar-square';
    protected static ?int $navigationSort = 2;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->with('user')
            ->whereHas('user', fn (Builder $query) => $query->where('school_id', static::schoolId()));
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('user.name')->label('Pengguna'),
            Forms\Components\TextInput::make('period_type')->label('Periode'),
            Forms\Components\TextInput::make('category')->label('Kategori'),
            Forms\Components\Textarea::make('recommendation_summary')->label('Rekomendasi')->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')->label('Pengguna')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('period_type')->label('Periode')->badge(),
                Tables\Columns\TextColumn::make('period_start')->label('Mulai')->date()->sortable(),
                Tables\Columns\TextColumn::make('period_end')->label('Akhir')->date()->sortable(),
                Tables\Columns\TextColumn::make('activity_count')->label('Activity')->numeric(),
                Tables\Columns\TextColumn::make('final_burnout_risk_score')->label('Skor')->numeric(decimalPlaces: 2),
                Tables\Columns\BadgeColumn::make('category')
                    ->label('Kategori')
                    ->colors([
                        'success' => 'low',
                        'warning' => 'moderate',
                        'danger' => 'high',
                    ]),
                Tables\Columns\TextColumn::make('created_at')->label('Dibuat')->dateTime()->sortable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchoolBurnoutAnalysisSnapshots::route('/'),
            'view' => Pages\ViewSchoolBurnoutAnalysisSnapshot::route('/{record}'),
        ];
    }
}
