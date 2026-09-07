<?php

namespace App\Filament\Admin\Resources\ParentResource\Pages;

use App\Filament\Admin\Resources\ParentResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListParents extends ListRecords
{
    protected static string $resource = ParentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
