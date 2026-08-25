<?php

namespace App\Filament\Admin\Resources\StudentObservationResource\Pages;

use App\Filament\Admin\Resources\StudentObservationResource;
use Filament\Resources\Pages\ListRecords;

class ListStudentObservations extends ListRecords
{
    protected static string $resource = StudentObservationResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
