<?php

namespace App\Filament\Admin\Resources\PendingTeacherResource\Pages;

use App\Filament\Admin\Resources\PendingTeacherResource;
use Filament\Resources\Pages\EditRecord;

class EditPendingTeacher extends EditRecord
{
    protected static string $resource = PendingTeacherResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
