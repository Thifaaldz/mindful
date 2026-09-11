<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\Concerns\HandlesSchoolUserApproval;
use App\Filament\School\Resources\StudentResource\Pages;
use App\Models\SchoolClass;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Hash;

class StudentResource extends Resource
{
    use BelongsToSchoolPanel;
    use HandlesSchoolUserApproval;

    protected static ?string $model = User::class;
    protected static ?string $navigationGroup = 'Murid';
    protected static ?string $navigationLabel = 'Data Murid';
    protected static ?string $modelLabel = 'Murid';
    protected static ?string $pluralModelLabel = 'Murid';
    protected static ?string $navigationIcon = 'heroicon-o-users';
    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->role('student')
            ->where('school_id', static::schoolId());
    }

    public static function canCreate(): bool
    {
        return (bool) auth()->user()?->isSchoolAdmin();
    }

    public static function canDelete($record): bool
    {
        return auth()->user()?->isSchoolAdmin()
            && (int) $record->school_id === (int) static::schoolId();
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->isSchoolAdmin()
            && (int) $record->school_id === (int) static::schoolId();
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Placeholder::make('school_display')
                ->label('Sekolah')
                ->content(fn () => auth()->user()?->schoolModel?->name ?? '-')
                ->columnSpanFull(),
            Forms\Components\TextInput::make('name')->label('Nama')->required()->maxLength(255),
            Forms\Components\TextInput::make('email')
                ->label('Email')
                ->email()
                ->required()
                ->unique(ignoreRecord: true)
                ->maxLength(255),
            Forms\Components\Select::make('class_id')
                ->label('Kelas')
                ->options(fn () => SchoolClass::query()
                    ->where('school_id', static::schoolId())
                    ->where('is_active', true)
                    ->orderBy('name')
                    ->pluck('name', 'id'))
                ->searchable()
                ->preload(),
            Forms\Components\TextInput::make('student_verification_code')
                ->label('Kode Orang Tua')
                ->disabled(),
            Forms\Components\Select::make('approval_status')
                ->label('Status Approval')
                ->options([
                    'pending' => 'Pending',
                    'approved' => 'Approved',
                    'rejected' => 'Rejected',
                ])
                ->default('approved')
                ->required(),
            Forms\Components\Textarea::make('rejection_reason')
                ->label('Alasan Penolakan')
                ->columnSpanFull(),
            Forms\Components\Section::make('Manajemen Password')
                ->description('Isi hanya jika pengguna lupa password atau perlu reset akses.')
                ->columns(2)
                ->schema([
                    Forms\Components\TextInput::make('password')
                        ->label('Password Baru')
                        ->password()
                        ->confirmed()
                        ->revealable()
                        ->minLength(8)
                        ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                        ->dehydrated(fn ($state) => filled($state))
                        ->required(fn (string $context): bool => $context === 'create'),
                    Forms\Components\TextInput::make('password_confirmation')
                        ->label('Konfirmasi Password Baru')
                        ->password()
                        ->revealable()
                        ->required(fn (string $context): bool => $context === 'create')
                        ->dehydrated(false),
                    Forms\Components\Toggle::make('must_change_password')
                        ->label('Wajib ganti password saat login berikutnya')
                        ->columnSpanFull(),
                ])
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('Nama')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('email')->label('Email')->searchable(),
                Tables\Columns\TextColumn::make('schoolClass.name')->label('Kelas')->sortable(),
                Tables\Columns\BadgeColumn::make('approval_status')
                    ->label('Status')
                    ->colors([
                        'success' => 'approved',
                        'warning' => 'pending',
                        'danger' => 'rejected',
                    ]),
                Tables\Columns\TextColumn::make('latestLoginHistory.logged_in_at')
                    ->label('Login Terakhir')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')->label('Daftar')->dateTime()->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('class_id')
                    ->label('Kelas')
                    ->options(fn () => SchoolClass::query()
                        ->where('school_id', static::schoolId())
                        ->orderBy('name')
                        ->pluck('name', 'id')),
                Tables\Filters\SelectFilter::make('approval_status')
                    ->label('Status')
                    ->options([
                        'pending' => 'Pending',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ]),
            ])
            ->actions([
                static::approveUserAction(),
                static::rejectUserAction(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStudents::route('/'),
            'create' => Pages\CreateStudent::route('/create'),
            'edit' => Pages\EditStudent::route('/{record}/edit'),
        ];
    }
}
