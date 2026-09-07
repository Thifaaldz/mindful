<?php

namespace App\Filament\School\Resources\TeacherResource\Pages;

use App\Filament\School\Resources\TeacherResource;
use App\Notifications\UserApprovedNotification;
use Filament\Resources\Pages\EditRecord;
use Throwable;

class EditTeacher extends EditRecord
{
    protected static string $resource = TeacherResource::class;

    protected bool $shouldSendApprovalNotification = false;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        if (($data['approval_status'] ?? null) === 'approved') {
            $this->shouldSendApprovalNotification = $this->record->approval_status !== 'approved';
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
        if (! $this->shouldSendApprovalNotification) {
            return;
        }

        try {
            $this->record->notify(new UserApprovedNotification($this->record));
        } catch (Throwable $exception) {
            report($exception);
        }
    }
}
