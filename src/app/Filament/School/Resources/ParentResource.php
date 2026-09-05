<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\ParentResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ParentResource extends Resource
{
    use BelongsToSchoolPanel;

    protected static ?string $model = User::class;
    protected static ?string $navigationGroup = 'Pengguna';
    protected static ?string $navigationLabel = 'Orang Tua';
    protected static ?string $modelLabel = 'Orang Tua';
    protected static ?string $pluralModelLabel = 'Orang Tua';
    protected static ?string $navigationIcon = 'heroicon-o-heart';
    protected static ?int $navigationSort = 3;

    public static function getEloquentQuery(): Builder
    {
        $schoolId = static::schoolId();

        return parent::getEloquentQuery()
            ->role('parent')
            ->where(function (Builder $query) use ($schoolId) {
                $query->where('school_id', $schoolId)
                    ->orWhereHas('parentChildren', fn (Builder $childQuery) => $childQuery->where('school_id', $schoolId));
            });
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
            Forms\Components\TextInput::make('name')->label('Nama'),
            Forms\Components\TextInput::make('email')->label('Email'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('Nama')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('email')->label('Email')->searchable(),
                Tables\Columns\TextColumn::make('parentChildren.name')
                    ->label('Anak')
                    ->badge(),
                Tables\Columns\TextColumn::make('latestLoginHistory.logged_in_at')
                    ->label('Login Terakhir')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')->label('Daftar')->dateTime()->sortable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListParents::route('/'),
            'view' => Pages\ViewParent::route('/{record}'),
        ];
    }
}
