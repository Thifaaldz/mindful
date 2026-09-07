<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\ParentResource\Pages;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

class ParentResource extends UserResource
{
    protected static ?string $navigationGroup = 'Orang Tua';
    protected static ?string $navigationLabel = 'Data Orang Tua';
    protected static ?string $modelLabel = 'Orang Tua';
    protected static ?string $pluralModelLabel = 'Orang Tua';
    protected static ?string $navigationIcon = 'heroicon-o-heart';
    protected static ?int $navigationSort = 1;
    protected static bool $shouldRegisterNavigation = true;

    public static function getEloquentQuery(): Builder
    {
        return User::query()
            ->with(['roles', 'schoolModel', 'schoolClass', 'latestLoginHistory'])
            ->role('parent');
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) User::role('parent')->count();
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListParents::route('/'),
            'create' => Pages\CreateParent::route('/create'),
            'edit' => Pages\EditParent::route('/{record}/edit'),
        ];
    }
}
