<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\SchoolProfileResource\Pages;
use App\Models\School;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SchoolProfileResource extends Resource
{
    use BelongsToSchoolPanel;

    protected static ?string $model = School::class;
    protected static ?string $navigationGroup = 'Sekolah';
    protected static ?string $navigationLabel = 'Profil Sekolah';
    protected static ?string $modelLabel = 'Profil Sekolah';
    protected static ?string $pluralModelLabel = 'Profil Sekolah';
    protected static ?string $navigationIcon = 'heroicon-o-building-office-2';
    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->whereKey(static::schoolId());
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Data Sekolah')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('name')
                        ->label('Nama Sekolah')
                        ->required()
                        ->maxLength(255),
                    Forms\Components\TextInput::make('npsn')
                        ->label('NPSN')
                        ->disabled(),
                    Forms\Components\Select::make('education_level')
                        ->label('Jenjang')
                        ->options([
                            'paud' => 'PAUD',
                            'tk' => 'TK',
                            'sd' => 'SD/MI',
                            'smp' => 'SMP/MTs',
                            'sma' => 'SMA/MA',
                            'smk' => 'SMK',
                            'other' => 'Lainnya',
                        ])
                        ->required(),
                    Forms\Components\Select::make('school_status')
                        ->label('Status Sekolah')
                        ->options([
                            'public' => 'Negeri',
                            'private' => 'Swasta',
                        ])
                        ->required(),
                    Forms\Components\Textarea::make('address')
                        ->label('Alamat')
                        ->columnSpanFull(),
                    Forms\Components\TextInput::make('province')
                        ->label('Provinsi')
                        ->maxLength(100),
                    Forms\Components\TextInput::make('city')
                        ->label('Kota/Kabupaten')
                        ->maxLength(100),
                    Forms\Components\TextInput::make('district')
                        ->label('Kecamatan')
                        ->maxLength(100),
                ]),
            Forms\Components\Section::make('Kontak')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('contact_name')
                        ->label('Nama Kontak')
                        ->maxLength(255),
                    Forms\Components\TextInput::make('contact_position')
                        ->label('Jabatan')
                        ->maxLength(120),
                    Forms\Components\TextInput::make('contact_email')
                        ->label('Email Kontak')
                        ->email()
                        ->maxLength(255),
                    Forms\Components\TextInput::make('contact_phone')
                        ->label('Nomor HP')
                        ->tel()
                        ->maxLength(30),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('Sekolah')->searchable(),
                Tables\Columns\TextColumn::make('npsn')->label('NPSN'),
                Tables\Columns\TextColumn::make('city')->label('Kota'),
                Tables\Columns\BadgeColumn::make('status')
                    ->label('Status')
                    ->colors([
                        'success' => 'approved',
                        'warning' => 'pending',
                        'danger' => 'rejected',
                        'gray' => 'suspended',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchoolProfiles::route('/'),
            'view' => Pages\ViewSchoolProfile::route('/{record}'),
            'edit' => Pages\EditSchoolProfile::route('/{record}/edit'),
        ];
    }
}
