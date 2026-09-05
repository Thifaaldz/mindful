<?php

namespace App\Filament\School\Resources;

use App\Filament\School\Resources\Concerns\BelongsToSchoolPanel;
use App\Filament\School\Resources\Concerns\HandlesSchoolUserApproval;
use App\Filament\School\Resources\PendingTeacherResource\Pages;
use App\Models\User;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class PendingTeacherResource extends Resource
{
    use BelongsToSchoolPanel;
    use HandlesSchoolUserApproval;

    protected static ?string $model = User::class;
    protected static ?string $navigationGroup = 'Pendaftaran';
    protected static ?string $navigationLabel = 'Guru Pending';
    protected static ?string $modelLabel = 'Guru Pending';
    protected static ?string $pluralModelLabel = 'Guru Pending';
    protected static ?string $navigationIcon = 'heroicon-o-user-plus';
    protected static ?int $navigationSort = 1;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->role('teacher')
            ->where('school_id', static::schoolId())
            ->where('approval_status', 'pending');
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('Nama')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('email')->label('Email')->searchable(),
                Tables\Columns\TextColumn::make('created_at')->label('Tanggal Daftar')->dateTime()->sortable(),
            ])
            ->actions([
                static::approveUserAction(),
                static::rejectUserAction(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPendingTeachers::route('/'),
        ];
    }
}
