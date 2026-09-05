<?php

namespace App\Policies;

use App\Models\School;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class SchoolPolicy
{
    use HandlesAuthorization;

    public function before(User $user): ?bool
    {
        return $user->hasRole('super_admin') ? true : null;
    }

    public function viewAny(User $user): bool
    {
        return $user->hasRole(['super_admin', 'admin']);
    }

    public function view(User $user, School $school): bool
    {
        return $user->hasRole(['super_admin', 'admin'])
            || ($user->hasRole('school_admin') && (int) $user->school_id === (int) $school->id);
    }

    public function create(User $user): bool
    {
        return $user->hasRole(['super_admin', 'admin']);
    }

    public function update(User $user, School $school): bool
    {
        return $user->hasRole(['super_admin', 'admin'])
            || ($user->hasRole('school_admin') && (int) $user->school_id === (int) $school->id);
    }

    public function delete(User $user, School $school): bool
    {
        return $user->hasRole(['super_admin', 'admin']);
    }

    public function deleteAny(User $user): bool
    {
        return $user->hasRole(['super_admin', 'admin']);
    }
}
