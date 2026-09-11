<?php

namespace App\Filament\School\Resources\StudentResource\Pages;

use App\Filament\School\Resources\StudentResource;
use App\Models\SchoolClass;
use Filament\Resources\Pages\EditRecord;

class EditStudent extends EditRecord
{
    protected static string $resource = StudentResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $school = auth()->user()?->schoolModel;

        if (filled($data['class_id'] ?? null)) {
            abort_unless(
                SchoolClass::query()
                    ->whereKey($data['class_id'])
                    ->where('school_id', $school?->id)
                    ->exists(),
                403,
                'Kelas ini bukan bagian dari sekolah Anda.'
            );
        }

        $data['school_id'] = $school?->id;
        $data['school'] = $school?->name;

        if (($data['approval_status'] ?? null) === 'approved') {
            $data['approved_at'] = $this->record->approved_at ?: now();
            $data['approved_by'] = $this->record->approved_by ?: auth()->id();
            $data['rejected_at'] = null;
            $data['rejected_by'] = null;
            $data['rejection_reason'] = null;
        }

        return $data;
    }

    protected function afterSave(): void
    {
        $this->record->syncRoles(['student']);
    }
}
