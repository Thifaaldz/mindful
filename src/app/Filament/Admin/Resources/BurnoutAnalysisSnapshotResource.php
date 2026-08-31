<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\BurnoutAnalysisSnapshotResource\Pages;
use App\Models\BurnoutAnalysisSnapshot;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class BurnoutAnalysisSnapshotResource extends Resource
{
    protected static ?string $model = BurnoutAnalysisSnapshot::class;

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar-square';

    protected static ?string $navigationGroup = 'Scoring & Ledger';

    protected static ?string $navigationLabel = 'Snapshot Analisis';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('user.name')
                ->label('User')
                ->disabled(),
            Forms\Components\TextInput::make('period_type')
                ->disabled(),
            Forms\Components\DatePicker::make('period_start')
                ->disabled(),
            Forms\Components\DatePicker::make('period_end')
                ->disabled(),
            Forms\Components\TextInput::make('workload_score_raw')
                ->disabled(),
            Forms\Components\TextInput::make('journal_score')
                ->disabled(),
            Forms\Components\TextInput::make('final_burnout_risk_score')
                ->disabled(),
            Forms\Components\TextInput::make('category')
                ->disabled(),
            Forms\Components\Textarea::make('recommendation_summary')
                ->formatStateUsing(fn ($state): string => json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) ?: '')
                ->disabled()
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('source')
                    ->badge(),
                Tables\Columns\TextColumn::make('period_type')
                    ->badge(),
                Tables\Columns\TextColumn::make('period_start')
                    ->date()
                    ->sortable(),
                Tables\Columns\TextColumn::make('workload_score_raw')
                    ->label('Workload Raw')
                    ->numeric(decimalPlaces: 2),
                Tables\Columns\TextColumn::make('journal_score')
                    ->numeric(decimalPlaces: 2),
                Tables\Columns\TextColumn::make('final_burnout_risk_score')
                    ->label('Final Risk')
                    ->numeric(decimalPlaces: 2)
                    ->sortable(),
                Tables\Columns\TextColumn::make('category')
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'merah' => 'danger',
                        'kuning' => 'warning',
                        'hijau' => 'success',
                        default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('data_sufficiency')
                    ->boolean(),
                Tables\Columns\TextColumn::make('scoring_version')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListBurnoutAnalysisSnapshots::route('/'),
            'view' => Pages\ViewBurnoutAnalysisSnapshot::route('/{record}'),
        ];
    }
}
