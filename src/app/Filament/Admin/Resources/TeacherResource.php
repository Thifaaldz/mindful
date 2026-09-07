<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\TeacherResource\Pages;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

class TeacherResource extends UserResource
{
    protected static ?string $navigationGroup = 'Guru';
    protected static ?string $navigationLabel = 'Data Guru';
    protected static ?string $modelLabel = 'Guru';
    protected static ?string $pluralModelLabel = 'Guru';
    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static ?int $navigationSort = 1;
    protected static bool $shouldRegisterNavigation = true;

    public static function getEloquentQuery(): Builder
    {
        return User::query()
            ->with(['roles', 'schoolModel', 'schoolClass', 'latestLoginHistory'])
            ->role('teacher');
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) User::role('teacher')->count();
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeachers::route('/'),
            'create' => Pages\CreateTeacher::route('/create'),
            'edit' => Pages\EditTeacher::route('/{record}/edit'),
        ];
    }
}
