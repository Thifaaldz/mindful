<?php

namespace App\Filament\Admin\Resources\StudentObservationResource\Pages;

use App\Filament\Admin\Resources\StudentObservationResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditStudentObservation extends EditRecord
{
    protected static string $resource = StudentObservationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
