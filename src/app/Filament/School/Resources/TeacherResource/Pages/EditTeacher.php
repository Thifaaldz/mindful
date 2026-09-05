<?php

namespace App\Filament\School\Resources\TeacherResource\Pages;

use App\Filament\School\Resources\TeacherResource;
use Filament\Resources\Pages\EditRecord;

class EditTeacher extends EditRecord
{
    protected static string $resource = TeacherResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        if (($data['approval_status'] ?? null) === 'approved') {
            $data['approved_at'] = $this->record->approved_at ?: now();
            $data['approved_by'] = $this->record->approved_by ?: auth()->id();
            $data['rejected_at'] = null;
            $data['rejected_by'] = null;
            $data['rejection_reason'] = null;
        }

        return $data;
    }
}
