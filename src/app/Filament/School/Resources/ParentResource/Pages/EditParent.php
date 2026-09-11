<?php

namespace App\Filament\School\Resources\ParentResource\Pages;

use App\Filament\School\Resources\ParentResource;
use Filament\Resources\Pages\EditRecord;

class EditParent extends EditRecord
{
    protected static string $resource = ParentResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $school = auth()->user()?->schoolModel;

        $data['school_id'] = $this->record->school_id ?: $school?->id;
        $data['school'] = $this->record->school ?: $school?->name;
        $data['class_id'] = null;
        $data['student_verification_code'] = null;
        $data['approval_status'] = 'approved';

        return $data;
    }

    protected function afterSave(): void
    {
        $this->record->syncRoles(['parent']);
    }
}
