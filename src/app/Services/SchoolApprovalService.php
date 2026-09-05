<?php

namespace App\Services;

use App\Models\School;
use App\Models\User;
use App\Notifications\SchoolApprovedNotification;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Str;

class SchoolApprovalService
{
    public function approve(School $school, User $superAdmin): User
    {
        return DB::transaction(function () use ($school, $superAdmin) {
            $school->forceFill([
                'status' => School::STATUS_APPROVED,
                'verified_at' => now(),
                'verified_by' => $superAdmin->id,
                'rejected_at' => null,
                'rejected_by' => null,
                'rejection_reason' => null,
            ])->save();

            $temporaryPassword = Str::password(12);
            $admin = $this->schoolAdminFor($school, $temporaryPassword);

            Notification::route('mail', $school->contact_email)
                ->notify(new SchoolApprovedNotification($school, $admin->email, $temporaryPassword));

            return $admin;
        });
    }

    public function reject(School $school, User $superAdmin, string $reason): void
    {
        $school->forceFill([
            'status' => School::STATUS_REJECTED,
            'rejected_at' => now(),
            'rejected_by' => $superAdmin->id,
            'rejection_reason' => $reason,
        ])->save();
    }

    private function schoolAdminFor(School $school, string $temporaryPassword): User
    {
        $email = $this->uniqueSchoolAdminEmail($school);

        $admin = User::firstOrCreate(
            ['school_id' => $school->id, 'email' => $email],
            [
                'name' => 'Admin '.$school->name,
                'password' => Hash::make($temporaryPassword),
                'school' => $school->name,
                'approval_status' => 'approved',
                'approved_at' => now(),
                'must_change_password' => true,
                'profile_completed' => true,
            ],
        );

        if (! $admin->wasRecentlyCreated) {
            $admin->forceFill([
                'password' => Hash::make($temporaryPassword),
                'name' => $admin->name ?: 'Admin '.$school->name,
                'school' => $school->name,
                'approval_status' => 'approved',
                'approved_at' => now(),
                'must_change_password' => true,
                'profile_completed' => true,
            ])->save();
        }

        $admin->syncRoles(['school_admin']);

        return $admin;
    }

    private function uniqueSchoolAdminEmail(School $school): string
    {
        $base = $school->slug ?: School::makeUniqueSlug($school->name, $school->id);
        $slug = $base;
        $suffix = 2;

        while (User::where('email', 'admin@'.$slug.'.test')
            ->where(function ($query) use ($school) {
                $query->whereNull('school_id')
                    ->orWhere('school_id', '!=', $school->id);
            })
            ->exists()) {
            $slug = $base.$suffix;
            $suffix++;
        }

        return 'admin@'.$slug.'.test';
    }
}
