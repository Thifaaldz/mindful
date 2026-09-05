<?php

namespace App\Filament\Admin\Resources\SchoolAdminResource\Pages;

use App\Filament\Admin\Resources\SchoolAdminResource;
use App\Models\School;
use Filament\Resources\Pages\CreateRecord;

class CreateSchoolAdmin extends CreateRecord
{
    protected static string $resource = SchoolAdminResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $school = School::find($data['school_id']);
        $data['school'] = $school?->name;
        $data['approval_status'] = 'approved';
        $data['approved_at'] = now();
        $data['profile_completed'] = true;

        return $data;
    }

    protected function afterCreate(): void
    {
        $this->record->syncRoles(['school_admin']);
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
