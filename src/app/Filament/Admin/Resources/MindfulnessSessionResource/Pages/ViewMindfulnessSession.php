<?php

namespace App\Filament\Admin\Resources\MindfulnessSessionResource\Pages;

use App\Filament\Admin\Resources\MindfulnessSessionResource;
use Filament\Actions;
use Filament\Resources\Pages\ViewRecord;

class ViewMindfulnessSession extends ViewRecord
{
    protected static string $resource = MindfulnessSessionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }
}
