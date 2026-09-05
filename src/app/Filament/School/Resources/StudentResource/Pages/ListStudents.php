<?php

namespace App\Filament\School\Resources\StudentResource\Pages;

use App\Filament\School\Resources\StudentResource;
use Filament\Resources\Pages\ListRecords;

class ListStudents extends ListRecords
{
    protected static string $resource = StudentResource::class;
}
