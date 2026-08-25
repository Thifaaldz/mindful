<?php

namespace App\Filament\Admin\Resources\MindfulnessSessionResource\Pages;

use App\Filament\Admin\Resources\MindfulnessSessionResource;
use Filament\Resources\Pages\ListRecords;

class ListMindfulnessSessions extends ListRecords
{
    protected static string $resource = MindfulnessSessionResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
