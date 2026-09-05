<?php

namespace App\Filament\School\Resources\Concerns;

trait BelongsToSchoolPanel
{
    protected static function schoolId(): ?int
    {
        return auth()->user()?->school_id;
    }

    public static function canViewAny(): bool
    {
        return (bool) auth()->user()?->isSchoolAdmin();
    }

    public static function canCreate(): bool
    {
        return (bool) auth()->user()?->isSchoolAdmin();
    }

    public static function canEdit($record): bool
    {
        return (bool) auth()->user()?->isSchoolAdmin();
    }

    public static function canDelete($record): bool
    {
        return false;
    }
}
