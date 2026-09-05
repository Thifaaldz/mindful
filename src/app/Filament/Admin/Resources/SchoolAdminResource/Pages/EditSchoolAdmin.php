<?php

namespace App\Filament\Admin\Resources\SchoolAdminResource\Pages;

use App\Filament\Admin\Resources\SchoolAdminResource;
use App\Models\School;
use Filament\Resources\Pages\EditRecord;

class EditSchoolAdmin extends EditRecord
{
    protected static string $resource = SchoolAdminResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $school = School::find($data['school_id']);
        $data['school'] = $school?->name;

        return $data;
    }

    protected function afterSave(): void
    {
        $this->record->syncRoles(['school_admin']);
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
