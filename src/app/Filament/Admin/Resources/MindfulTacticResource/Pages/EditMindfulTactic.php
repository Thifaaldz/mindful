<?php

namespace App\Filament\Admin\Resources\MindfulTacticResource\Pages;

use App\Filament\Admin\Resources\MindfulTacticResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditMindfulTactic extends EditRecord
{
    protected static string $resource = MindfulTacticResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
