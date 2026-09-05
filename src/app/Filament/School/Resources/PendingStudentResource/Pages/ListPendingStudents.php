<?php

namespace App\Filament\School\Resources\PendingStudentResource\Pages;

use App\Filament\School\Resources\PendingStudentResource;
use Filament\Resources\Pages\ListRecords;

class ListPendingStudents extends ListRecords
{
    protected static string $resource = PendingStudentResource::class;
}
