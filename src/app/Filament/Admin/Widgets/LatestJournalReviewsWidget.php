<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Activity;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class LatestJournalReviewsWidget extends BaseWidget
{
    protected static ?int $sort = 4;

    protected int|string|array $columnSpan = 2;

    protected static ?string $heading = 'Review Journal Terbaru';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Activity::query()
                    ->with(['owner:id,name,school'])
                    ->whereNotNull('checkout_at')
                    ->whereNotNull('checkout_suggestion')
                    ->latest('checkout_at')
                    ->limit(10)
            )
            ->columns([
                Tables\Columns\TextColumn::make('owner.name')
                    ->label('User')
                    ->searchable(),
                Tables\Columns\TextColumn::make('title')
                    ->label('Activity')
                    ->limit(28)
                    ->searchable(),
                Tables\Columns\TextColumn::make('checkout_mood_detected')
                    ->label('Mood')
                    ->badge()
                    ->colors([
                        'success' => ['senang', 'tenang', 'netral'],
                        'warning' => ['cemas', 'sedih', 'lelah'],
                        'danger' => ['marah'],
                    ]),
                Tables\Columns\TextColumn::make('checkout_analysis_source')
                    ->label('Tipe Analisis')
                    ->badge()
                    ->formatStateUsing(
                        fn (?string $state) => in_array($state, ['gemini', 'fastapi'], true) ? 'Berbasis AI' : 'Lokal'
                    )
                    ->colors([
                        'success' => ['gemini', 'fastapi'],
                        'gray' => ['php-fallback', 'mock'],
                    ]),
                Tables\Columns\TextColumn::make('checkout_suggestion')
                    ->label('Review AI')
                    ->limit(62)
                    ->wrap(),
                Tables\Columns\IconColumn::make('checkout_crisis_flag')
                    ->label('Merah')
                    ->boolean(),
                Tables\Columns\TextColumn::make('checkout_at')
                    ->label('Waktu')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->paginated(false);
    }
}
