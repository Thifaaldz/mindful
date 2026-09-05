<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\UserResource\Pages;
use App\Filament\Admin\Resources\UserResource\RelationManagers\LoginHistoriesRelationManager;
use App\Models\School;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Hash;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    protected static ?string $navigationGroup = 'Pengguna';

    protected static ?string $recordTitleAttribute = 'name';

    protected static ?int $navigationSort = -2;

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::count();
    }

    public static function getGloballySearchableAttributes(): array
    {
        return ['name', 'email', 'roles.name'];
    }

    public static function getGlobalSearchResultDetails(Model $record): array
    {
        return [
            'Role' => $record->roles->pluck('name')->implode(', '),
            'Email' => $record->email,
        ];
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([

                Forms\Components\Grid::make(2)
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->minLength(2)
                            ->maxLength(255)
                            ->columnSpan('full')
                            ->required(),
                        Forms\Components\FileUpload::make('avatar_url')
                            ->label('Avatar')
                            ->image()
                            ->optimize('webp')
                            ->imageEditor()
                            ->imagePreviewHeight('250')
                            ->panelAspectRatio('7:2')
                            ->panelLayout('integrated')
                            ->columnSpan('full'),
                        Forms\Components\TextInput::make('email')
                            ->required()
                            ->prefixIcon('heroicon-m-envelope')
                            ->columnSpan('full')
                            ->email(),
                        Forms\Components\Select::make('school_id')
                            ->label('Sekolah')
                            ->options(fn () => School::approved()->orderBy('name')->pluck('name', 'id'))
                            ->searchable()
                            ->preload()
                            ->afterStateUpdated(function ($state, Forms\Set $set) {
                                $set('school', School::find($state)?->name);
                            }),
                        Forms\Components\TextInput::make('school')
                            ->label('Sekolah Legacy')
                            ->maxLength(255)
                            ->helperText('Diisi otomatis dari School jika tersedia.'),
                        Forms\Components\Select::make('class_id')
                            ->label('Kelas (untuk siswa)')
                            ->options(fn (Forms\Get $get) => \App\Models\SchoolClass::query()
                                ->when($get('school_id'), fn ($query, $schoolId) => $query->where('school_id', $schoolId))
                                ->orderBy('name')
                                ->pluck('name', 'id'))
                            ->searchable()
                            ->preload(),
                        Forms\Components\Select::make('approval_status')
                            ->label('Status Approval')
                            ->options([
                                'pending' => 'Pending',
                                'approved' => 'Approved',
                                'rejected' => 'Rejected',
                            ])
                            ->default('approved')
                            ->required(),

                        Forms\Components\TextInput::make('password')
                            ->password()
                            ->confirmed()
                            ->columnSpan(1)
                            ->dehydrateStateUsing(fn ($state) => Hash::make($state))
                            ->dehydrated(fn ($state) => filled($state))
                            ->required(fn (string $context): bool => $context === 'create'),
                        Forms\Components\TextInput::make('password_confirmation')
                            ->required(fn (string $context): bool => $context === 'create')
                            ->columnSpan(1)
                            ->password(),
                    ]),

                Forms\Components\Section::make('Roles')
                    ->schema([
                        Forms\Components\Select::make('roles')
                            ->required()
                            ->multiple()
                            ->relationship('roles', 'name')
                            ->label('Roles'),
                    ])
                    ->columns(1),

            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->sortable()
                    ->searchable(),
                Tables\Columns\TextColumn::make('name')
                    ->sortable()
                    ->searchable(),
                Tables\Columns\ImageColumn::make('avatar_url')
                    ->defaultImageUrl(url('https://www.gravatar.com/avatar/64e1b8d34f425d19e1ee2ea7236d3028?d=mp&r=g&s=250'))
                    ->label('Avatar')
                    ->circular(),
                Tables\Columns\TextColumn::make('email')
                    ->sortable()
                    ->searchable(),
                Tables\Columns\TextColumn::make('roles.name')
                    ->badge()
                    ->sortable()
                    ->searchable(),
                Tables\Columns\TextColumn::make('school')
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->searchable(),
                Tables\Columns\TextColumn::make('schoolModel.name')
                    ->label('Sekolah')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('schoolClass.name')
                    ->label('Kelas')
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('approval_status')
                    ->label('Approval')
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'approved' => 'success',
                        'rejected' => 'danger',
                        'pending' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('latestLoginHistory.logged_in_at')
                    ->label('Last Login')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('latestLoginHistory.device_name')
                    ->label('Device')
                    ->limit(24)
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('created_at')
                    ->date()
                    ->sortable()
                    ->searchable(),

            ])
            ->filters([
                Tables\Filters\SelectFilter::make('roles')
                    ->relationship('roles', 'name')
                    ->label('Role'),
                Tables\Filters\SelectFilter::make('school_id')
                    ->label('Sekolah')
                    ->options(fn () => School::orderBy('name')->pluck('name', 'id')),
                Tables\Filters\SelectFilter::make('approval_status')
                    ->label('Approval')
                    ->options([
                        'pending' => 'Pending',
                        'approved' => 'Approved',
                        'rejected' => 'Rejected',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),

            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    // Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->emptyStateActions([
                Tables\Actions\CreateAction::make(),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            LoginHistoriesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
