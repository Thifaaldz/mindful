<?php

namespace App\Filament\School\Resources\StudentResource\Pages;

use App\Filament\School\Resources\StudentResource;
use App\Models\SchoolClass;
use App\Models\User;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateStudent extends CreateRecord
{
    protected static string $resource = StudentResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $school = auth()->user()?->schoolModel;

        if (filled($data['class_id'] ?? null)) {
            abort_unless(
                SchoolClass::query()
                    ->whereKey($data['class_id'])
                    ->where('school_id', $school?->id)
                    ->exists(),
                403,
                'Kelas ini bukan bagian dari sekolah Anda.'
            );
        }

        $data['school_id'] = $school?->id;
        $data['school'] = $school?->name;
        $data['student_verification_code'] = $data['student_verification_code']
            ?? $this->newStudentVerificationCode();
        $data['approval_status'] = $data['approval_status'] ?? 'approved';

        if ($data['approval_status'] === 'approved') {
            $data['approved_at'] = now();
            $data['approved_by'] = auth()->id();
        }

        return $data;
    }

    protected function afterCreate(): void
    {
        $this->record->syncRoles(['student']);
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    private function newStudentVerificationCode(): string
    {
        do {
            $code = strtoupper(Str::random(8));
        } while (User::where('student_verification_code', $code)->exists());

        return $code;
    }
}
