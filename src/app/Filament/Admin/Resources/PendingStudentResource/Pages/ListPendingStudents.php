<?php

namespace App\Filament\Admin\Resources\PendingStudentResource\Pages;

use App\Filament\Admin\Resources\PendingStudentResource;
use Filament\Resources\Pages\ListRecords;

class ListPendingStudents extends ListRecords
{
    protected static string $resource = PendingStudentResource::class;
}
