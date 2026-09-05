<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\SchoolClassResource\Pages;
use App\Filament\Admin\Resources\SchoolClassResource\RelationManagers;
use App\Models\School;
use App\Models\SchoolClass;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class SchoolClassResource extends Resource
{
    protected static ?string $model = SchoolClass::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static ?string $navigationGroup = 'Akademik';

    protected static ?string $navigationLabel = 'Kelas';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Nama Kelas')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Select::make('school_id')
                    ->label('Sekolah')
                    ->options(fn () => School::approved()->orderBy('name')->pluck('name', 'id'))
                    ->searchable()
                    ->preload()
                    ->afterStateUpdated(fn ($state, Forms\Set $set) => $set('school', School::find($state)?->name)),
                Forms\Components\TextInput::make('school')
                    ->label('Sekolah Legacy')
                    ->maxLength(255),
                Forms\Components\TextInput::make('grade')
                    ->label('Tingkat')
                    ->maxLength(255)
                    ->default(null),
                Forms\Components\TextInput::make('academic_year')
                    ->label('Tahun Ajaran')
                    ->maxLength(20),
                Forms\Components\Toggle::make('is_active')
                    ->label('Aktif')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nama Kelas')
                    ->searchable(),
                Tables\Columns\TextColumn::make('schoolModel.name')
                    ->label('Sekolah')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('grade')
                    ->label('Tingkat')
                    ->searchable(),
                Tables\Columns\TextColumn::make('academic_year')
                    ->label('Tahun Ajaran')
                    ->toggleable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Aktif')
                    ->boolean(),
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
                Tables\Filters\SelectFilter::make('school_id')
                    ->label('Sekolah')
                    ->options(fn () => School::orderBy('name')->pluck('name', 'id')),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Aktif'),
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
            'index' => Pages\ListSchoolClasses::route('/'),
            'create' => Pages\CreateSchoolClass::route('/create'),
            'edit' => Pages\EditSchoolClass::route('/{record}/edit'),
        ];
    }
}
