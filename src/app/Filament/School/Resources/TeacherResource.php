<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\Concerns\HandlesSchoolUserApproval;
use App\Filament\School\Resources\TeacherResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class TeacherResource extends Resource
{
    use BelongsToSchoolPanel;
    use HandlesSchoolUserApproval;

    protected static ?string $model = User::class;
    protected static ?string $navigationGroup = 'Pengguna';
    protected static ?string $navigationLabel = 'Guru';
    protected static ?string $modelLabel = 'Guru';
    protected static ?string $pluralModelLabel = 'Guru';
    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->role('teacher')
            ->where('school_id', static::schoolId());
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('name')->label('Nama')->required()->maxLength(255),
            Forms\Components\TextInput::make('email')->label('Email')->email()->required()->maxLength(255),
            Forms\Components\Select::make('approval_status')
                ->label('Status Approval')
                ->options([
                    'pending' => 'Pending',
                    'approved' => 'Approved',
                    'rejected' => 'Rejected',
                ])
                ->required(),
            Forms\Components\Textarea::make('rejection_reason')
                ->label('Alasan Penolakan')
                ->columnSpanFull(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('Nama')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('email')->label('Email')->searchable(),
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
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeachers::route('/'),
            'edit' => Pages\EditTeacher::route('/{record}/edit'),
        ];
    }
}
