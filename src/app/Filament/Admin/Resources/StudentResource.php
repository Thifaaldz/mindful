<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\StudentResource\Pages;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

class StudentResource extends UserResource
{
    protected static ?string $navigationGroup = 'Murid';
    protected static ?string $navigationLabel = 'Data Murid';
    protected static ?string $modelLabel = 'Murid';
    protected static ?string $pluralModelLabel = 'Murid';
    protected static ?string $navigationIcon = 'heroicon-o-users';
    protected static ?int $navigationSort = 1;
    protected static bool $shouldRegisterNavigation = true;

    public static function getEloquentQuery(): Builder
    {
        return User::query()
            ->with(['roles', 'schoolModel', 'schoolClass', 'latestLoginHistory'])
            ->role('student');
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) User::role('student')->count();
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
