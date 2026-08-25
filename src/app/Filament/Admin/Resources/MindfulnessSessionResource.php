<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\MindfulnessSessionResource\Pages;
use App\Models\MindfulnessSession;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class MindfulnessSessionResource extends Resource
{
    protected static ?string $model = MindfulnessSession::class;

    protected static ?string $navigationIcon = 'heroicon-o-clock';

    protected static ?string $navigationGroup = 'Aktivitas Guru';

    protected static ?string $recordTitleAttribute = 'user.name';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->required(),
                Forms\Components\DateTimePicker::make('started_at')
                    ->required(),
                Forms\Components\DateTimePicker::make('completed_at'),
                Forms\Components\TextInput::make('duration_seconds')
                    ->required()
                    ->numeric()
                    ->default(0),
                Forms\Components\TextInput::make('distraction_score')
                    ->required()
                    ->numeric()
                    ->default(0),
                Forms\Components\TextInput::make('calmness_before')
                    ->numeric()
                    ->default(null),
                Forms\Components\TextInput::make('calmness_after')
                    ->numeric()
                    ->default(null),
                Forms\Components\Textarea::make('reflection')
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('status')
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('started_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('completed_at')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('duration_seconds')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('distraction_score')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('calmness_before')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('calmness_after')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->colors(['success' => 'completed', 'warning' => 'in_progress']),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('started_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(['in_progress' => 'Sedang Berjalan', 'completed' => 'Selesai']),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListMindfulnessSessions::route('/'),
            'view' => Pages\ViewMindfulnessSession::route('/{record}'),
        ];
    }
}
