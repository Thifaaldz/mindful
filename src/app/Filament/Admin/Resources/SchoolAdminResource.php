<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\SchoolAdminResource\Pages;
use App\Models\School;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Hash;

class SchoolAdminResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-shield-check';

    protected static ?string $navigationGroup = 'Sekolah';

    protected static ?string $navigationLabel = 'Admin Sekolah';

    protected static ?int $navigationSort = 3;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('name')
                ->label('Nama')
                ->required()
                ->maxLength(255),
            Forms\Components\TextInput::make('email')
                ->label('Email Login')
                ->email()
                ->required()
                ->maxLength(255)
                ->unique(ignoreRecord: true),
            Forms\Components\Select::make('school_id')
                ->label('Sekolah')
                ->options(fn () => School::approved()->orderBy('name')->pluck('name', 'id'))
                ->searchable()
                ->preload()
                ->required(),
            Forms\Components\TextInput::make('password')
                ->password()
                ->confirmed()
                ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                ->dehydrated(fn ($state) => filled($state))
                ->required(fn (string $context): bool => $context === 'create'),
            Forms\Components\TextInput::make('password_confirmation')
                ->password()
                ->required(fn (string $context): bool => $context === 'create'),
            Forms\Components\Toggle::make('must_change_password')
                ->label('Wajib ganti password')
                ->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nama')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('email')
                    ->label('Email Login')
                    ->searchable(),
                Tables\Columns\TextColumn::make('schoolModel.name')
                    ->label('Sekolah')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\IconColumn::make('must_change_password')
                    ->label('Wajib Ganti Password')
                    ->boolean(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('school_id')
                    ->label('Sekolah')
                    ->options(fn () => School::orderBy('name')->pluck('name', 'id')),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([]);
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->role('school_admin')
            ->with('schoolModel');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchoolAdmins::route('/'),
            'create' => Pages\CreateSchoolAdmin::route('/create'),
            'edit' => Pages\EditSchoolAdmin::route('/{record}/edit'),
        ];
    }
}
