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
use Illuminate\Support\Facades\Hash;

class ParentResource extends Resource
{
    use BelongsToSchoolPanel;

    protected static ?string $model = User::class;
    protected static ?string $navigationGroup = 'Orang Tua';
    protected static ?string $navigationLabel = 'Parent Management';
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
        return (bool) auth()->user()?->isSchoolAdmin();
    }

    public static function canEdit($record): bool
    {
        return auth()->user()?->isSchoolAdmin()
            && static::parentBelongsToSchool($record);
    }

    public static function canView($record): bool
    {
        return auth()->user()?->isSchoolAdmin()
            && static::parentBelongsToSchool($record);
    }

    public static function canDelete($record): bool
    {
        return auth()->user()?->isSchoolAdmin()
            && static::parentBelongsToSchool($record)
            && ! $record->parentChildren()
                ->where('school_id', '!=', static::schoolId())
                ->exists();
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
            Forms\Components\Section::make('Manajemen Password')
                ->description('Isi hanya jika orang tua lupa password atau perlu reset akses.')
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
                Tables\Columns\TextColumn::make('parentChildren.name')
                    ->label('Anak')
                    ->getStateUsing(fn (User $record): array => $record->parentChildren()
                        ->where('school_id', static::schoolId())
                        ->orderBy('name')
                        ->pluck('name')
                        ->all())
                    ->badge(),
                Tables\Columns\TextColumn::make('latestLoginHistory.logged_in_at')
                    ->label('Login Terakhir')
                    ->dateTime()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')->label('Daftar')->dateTime()->sortable(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListParents::route('/'),
            'create' => Pages\CreateParent::route('/create'),
            'view' => Pages\ViewParent::route('/{record}'),
            'edit' => Pages\EditParent::route('/{record}/edit'),
        ];
    }

    private static function parentBelongsToSchool(User $record): bool
    {
        $schoolId = static::schoolId();

        return (int) $record->school_id === (int) $schoolId
            || $record->parentChildren()
                ->where('school_id', $schoolId)
                ->exists();
    }
}
