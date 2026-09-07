<?php

namespace App\Filament\Admin\Resources\PendingStudentResource\Pages;

use App\Filament\Admin\Resources\PendingStudentResource;
use Filament\Resources\Pages\EditRecord;

class EditPendingStudent extends EditRecord
{
    protected static string $resource = PendingStudentResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
