<?php

namespace App\Filament\School\Resources\TeacherResource\Pages;

use App\Filament\School\Resources\TeacherResource;
use Filament\Resources\Pages\CreateRecord;

class CreateTeacher extends CreateRecord
{
    protected static string $resource = TeacherResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $school = auth()->user()?->schoolModel;

        $data['school_id'] = $school?->id;
        $data['school'] = $school?->name;
        $data['class_id'] = null;
        $data['student_verification_code'] = null;
        $data['approval_status'] = $data['approval_status'] ?? 'approved';

        if ($data['approval_status'] === 'approved') {
            $data['approved_at'] = now();
            $data['approved_by'] = auth()->id();
        }

        return $data;
    }

    protected function afterCreate(): void
    {
        $this->record->syncRoles(['teacher']);
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
