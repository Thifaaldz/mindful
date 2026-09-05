<?php

namespace App\Filament\Admin\Resources\SchoolResource\Pages;

use App\Filament\Admin\Resources\SchoolResource;
use App\Models\School;
use Filament\Resources\Pages\CreateRecord;

class CreateSchool extends CreateRecord
{
    protected static string $resource = SchoolResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['slug'] = $data['slug'] ?: School::makeUniqueSlug($data['name']);

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}
