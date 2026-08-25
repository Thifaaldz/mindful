<?php

namespace App\Filament\Admin\Resources\StudentObservationResource\Pages;

use App\Filament\Admin\Resources\StudentObservationResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewStudentObservation extends ViewRecord
{
    protected static string $resource = StudentObservationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
