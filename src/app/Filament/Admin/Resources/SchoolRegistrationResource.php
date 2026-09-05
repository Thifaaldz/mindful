<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\SchoolRegistrationResource\Pages;
use App\Models\School;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class SchoolRegistrationResource extends Resource
{
    protected static ?string $model = School::class;

    protected static ?string $navigationIcon = 'heroicon-o-inbox-arrow-down';

    protected static ?string $navigationGroup = 'Sekolah';

    protected static ?string $navigationLabel = 'Pendaftaran Sekolah';

    protected static ?int $navigationSort = 1;

    public static function form(Form $form): Form
    {
        return $form->schema(SchoolResource::schoolFormSchema());
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns(SchoolResource::schoolTableColumns())
            ->actions([
                Tables\Actions\ViewAction::make(),
                SchoolResource::approveAction(),
                SchoolResource::rejectAction(),
            ])
            ->bulkActions([])
            ->defaultSort('created_at', 'desc');
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->where('status', School::STATUS_PENDING);
    }

    public static function getNavigationBadge(): ?string
    {
        $count = School::where('status', School::STATUS_PENDING)->count();

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

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSchoolRegistrations::route('/'),
            'view' => Pages\ViewSchoolRegistration::route('/{record}'),
        ];
    }
}
