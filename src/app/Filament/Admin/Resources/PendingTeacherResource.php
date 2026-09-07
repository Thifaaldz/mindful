<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\PendingTeacherResource\Pages;
use App\Filament\School\Resources\Concerns\HandlesSchoolUserApproval;
use App\Models\User;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class PendingTeacherResource extends TeacherResource
{
    use HandlesSchoolUserApproval;

    protected static ?string $navigationGroup = 'Guru';
    protected static ?string $navigationLabel = 'Pendaftaran Guru';
    protected static ?string $modelLabel = 'Pendaftaran Guru';
    protected static ?string $pluralModelLabel = 'Pendaftaran Guru';
    protected static ?string $navigationIcon = 'heroicon-o-user-plus';
    protected static ?int $navigationSort = 0;
    protected static bool $shouldRegisterNavigation = true;

    public static function getEloquentQuery(): Builder
    {
        return User::query()
            ->with(['roles', 'schoolModel', 'schoolClass', 'latestLoginHistory'])
            ->role('teacher')
            ->where('approval_status', 'pending');
    }

    public static function getNavigationBadge(): ?string
    {
        $count = User::role('teacher')->where('approval_status', 'pending')->count();

        return $count > 0 ? (string) $count : null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
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
                Tables\Columns\TextColumn::make('schoolModel.name')->label('Sekolah')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('created_at')->label('Tanggal Daftar')->dateTime()->sortable(),
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
            'index' => Pages\ListPendingTeachers::route('/'),
            'edit' => Pages\EditPendingTeacher::route('/{record}/edit'),
        ];
    }
}
