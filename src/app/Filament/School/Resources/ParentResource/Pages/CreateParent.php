<?php

namespace App\Filament\School\Resources\ParentResource\Pages;

use App\Filament\School\Resources\ParentResource;
use Filament\Resources\Pages\CreateRecord;

class CreateParent extends CreateRecord
{
    protected static string $resource = ParentResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $school = auth()->user()?->schoolModel;

        $data['school_id'] = $school?->id;
        $data['school'] = $school?->name;
        $data['class_id'] = null;
        $data['student_verification_code'] = null;
        $data['approval_status'] = 'approved';
        $data['approved_at'] = now();
        $data['approved_by'] = auth()->id();

        return $data;
    }

    protected function afterCreate(): void
    {
        $this->record->syncRoles(['parent']);
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
