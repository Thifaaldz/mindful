<?php

namespace App\Filament\Admin\Widgets;

use App\Models\StudentObservation;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;

class FlaggedStudentsWidget extends BaseWidget
{
    protected static ?int $sort = 5;

    protected int|string|array $columnSpan = 'full';

    protected static ?string $heading = 'Siswa yang Perlu Perhatian';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                StudentObservation::query()
                    ->whereIn('status', ['kuning', 'merah'])
                    ->latest('observed_on')
            )
            ->columns([
                Tables\Columns\TextColumn::make('student.name')
                    ->label('Siswa'),
                Tables\Columns\TextColumn::make('schoolClass.name')
                    ->label('Kelas'),
                Tables\Columns\TextColumn::make('teacher.name')
                    ->label('Dilaporkan oleh'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->colors(['warning' => 'kuning', 'danger' => 'merah']),
                Tables\Columns\TextColumn::make('observed_on')
                    ->date()
                    ->label('Tanggal'),
            ])
            ->paginated([5, 10, 25]);
    }
}
