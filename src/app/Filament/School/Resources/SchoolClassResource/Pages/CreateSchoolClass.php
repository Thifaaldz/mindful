<?php

namespace App\Filament\School\Resources\SchoolClassResource\Pages;

use App\Filament\School\Resources\SchoolClassResource;
use Filament\Resources\Pages\CreateRecord;

class CreateSchoolClass extends CreateRecord
{
    protected static string $resource = SchoolClassResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $school = auth()->user()?->schoolModel;

        $data['school_id'] = $school?->id;
        $data['school'] = $school?->name;

        return $data;
    }
}
