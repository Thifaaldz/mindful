<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\SchoolClassResource\Pages;
use App\Models\SchoolClass;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SchoolClassResource extends Resource
{
    use BelongsToSchoolPanel;

    protected static ?string $model = SchoolClass::class;
    protected static ?string $navigationGroup = 'Sekolah';
    protected static ?string $navigationLabel = 'Kelas';
    protected static ?string $modelLabel = 'Kelas';
    protected static ?string $pluralModelLabel = 'Kelas';
    protected static ?string $navigationIcon = 'heroicon-o-academic-cap';
    protected static ?int $navigationSort = 2;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where('school_id', static::schoolId());
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('name')
                ->label('Nama Kelas')
                ->placeholder('5A')
                ->required()
                ->maxLength(80),
            Forms\Components\TextInput::make('grade')
                ->label('Tingkat')
                ->maxLength(20),
            Forms\Components\TextInput::make('academic_year')
                ->label('Tahun Ajaran')
                ->placeholder('2026/2027')
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
                Tables\Columns\TextColumn::make('name')->label('Kelas')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('grade')->label('Tingkat')->sortable(),
                Tables\Columns\TextColumn::make('academic_year')->label('Tahun Ajaran'),
                Tables\Columns\IconColumn::make('is_active')->label('Aktif')->boolean(),
                Tables\Columns\TextColumn::make('created_at')->label('Dibuat')->dateTime()->sortable(),
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

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchoolClasses::route('/'),
            'create' => Pages\CreateSchoolClass::route('/create'),
            'edit' => Pages\EditSchoolClass::route('/{record}/edit'),
        ];
    }
}
