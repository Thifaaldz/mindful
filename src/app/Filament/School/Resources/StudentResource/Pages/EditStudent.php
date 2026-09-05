<?php

namespace App\Filament\School\Resources\StudentResource\Pages;

use App\Filament\School\Resources\StudentResource;
use Filament\Resources\Pages\EditRecord;

class EditStudent extends EditRecord
{
    protected static string $resource = StudentResource::class;

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
