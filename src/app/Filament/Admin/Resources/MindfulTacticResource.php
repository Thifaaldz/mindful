<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\MindfulTacticResource\Pages;
use App\Filament\Admin\Resources\MindfulTacticResource\RelationManagers;
use App\Models\MindfulTactic;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class MindfulTacticResource extends Resource
{
    protected static ?string $model = MindfulTactic::class;

    protected static ?string $navigationIcon = 'heroicon-o-light-bulb';

    protected static ?string $navigationGroup = 'Konten';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255),
                Forms\Components\TextInput::make('category')
                    ->maxLength(255)
                    ->default(null),
                Forms\Components\Textarea::make('description')
                    ->required()
                    ->columnSpanFull(),
                Forms\Components\Textarea::make('knowledge')
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('duration_minutes')
                    ->required()
                    ->numeric()
                    ->default(3),
                Forms\Components\TagsInput::make('best_for')
                    ->columnSpanFull(),
                Forms\Components\TagsInput::make('steps')
                    ->columnSpanFull(),
                Forms\Components\TagsInput::make('cues')
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('sort_order')
                    ->required()
                    ->numeric()
                    ->default(0),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->searchable(),
                Tables\Columns\TextColumn::make('category')
                    ->searchable(),
                Tables\Columns\TextColumn::make('duration_minutes')
                    ->numeric()
                    ->suffix(' menit')
                    ->sortable(),
                Tables\Columns\TextColumn::make('sort_order')
                    ->numeric()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
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
            'index' => Pages\ListMindfulTactics::route('/'),
            'create' => Pages\CreateMindfulTactic::route('/create'),
            'edit' => Pages\EditMindfulTactic::route('/{record}/edit'),
        ];
    }
}
