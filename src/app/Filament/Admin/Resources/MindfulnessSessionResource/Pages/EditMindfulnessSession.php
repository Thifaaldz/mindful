<?php

namespace App\Filament\Admin\Resources\MindfulnessSessionResource\Pages;

use App\Filament\Admin\Resources\MindfulnessSessionResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditMindfulnessSession extends EditRecord
{
    protected static string $resource = MindfulnessSessionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\ViewAction::make(),
            Actions\DeleteAction::make(),
        ];
    }
}
