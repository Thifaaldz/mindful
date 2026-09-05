<?php

use App\Models\Activity;
use App\Models\School;
use App\Models\SchoolClass;
use App\Models\User;
use App\Services\SchoolApprovalService;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Laravel\Sanctum\Sanctum;
use Spatie\Permission\Models\Role;

uses(RefreshDatabase::class);

beforeEach(function () {
    foreach (['super_admin', 'school_admin', 'teacher', 'student', 'parent'] as $role) {
        Role::create(['name' => $role]);
    }
});

test('public school registration creates a pending school request', function () {
    $this->post('/register-school', [
        'name' => 'SD Mindful Baru',
        'npsn' => 'NPSN-NEW-001',
        'education_level' => 'sd',
        'school_status' => 'public',
        'address' => 'Jl. Sekolah Baru',
        'province' => 'DKI Jakarta',
        'city' => 'Jakarta',
        'district' => 'Setiabudi',
        'contact_name' => 'Ibu Kepala',
        'contact_position' => 'Kepala Sekolah',
        'contact_email' => 'kepala@sdmindful.test',
        'contact_phone' => '080000000123',
    ])->assertRedirect();

    $school = School::where('npsn', 'NPSN-NEW-001')->first();

    expect($school)->not->toBeNull()
        ->and($school->status)->toBe(School::STATUS_PENDING)
        ->and($school->slug)->not->toBeEmpty();
});

test('super admin approval creates school admin access without changing admin panel access', function () {
    Notification::fake();

    $superAdmin = User::factory()->create([
        'email' => 'super@mindfuledu.test',
    ]);
    $superAdmin->assignRole('super_admin');

    $school = School::create([
        'name' => 'SD Mindful Approved',
        'slug' => 'sd-mindful-approved',
        'npsn' => 'NPSN-APPROVED-001',
        'education_level' => 'sd',
        'school_status' => 'public',
        'address' => 'Jl. Approved',
        'province' => 'DKI Jakarta',
        'city' => 'Jakarta',
        'contact_name' => 'Kontak Sekolah',
        'contact_email' => 'kontak@approved.test',
        'status' => School::STATUS_PENDING,
    ]);

    $schoolAdmin = app(SchoolApprovalService::class)->approve($school, $superAdmin);

    expect($school->refresh()->status)->toBe(School::STATUS_APPROVED)
        ->and($schoolAdmin->email)->toBe('admin@sd-mindful-approved.test')
        ->and($schoolAdmin->hasRole('school_admin'))->toBeTrue()
        ->and($schoolAdmin->school_id)->toBe($school->id)
        ->and($schoolAdmin->must_change_password)->toBeTrue()
        ->and($superAdmin->canAccessPanel(Filament::getPanel('admin')))->toBeTrue()
        ->and($superAdmin->canAccessPanel(Filament::getPanel('school')))->toBeFalse()
        ->and($schoolAdmin->canAccessPanel(Filament::getPanel('school')))->toBeTrue()
        ->and($schoolAdmin->canAccessPanel(Filament::getPanel('admin')))->toBeFalse();
});

test('public dropdown endpoints expose approved schools and active classes only', function () {
    $approved = School::create([
        'name' => 'SD Approved',
        'slug' => 'sd-approved',
        'npsn' => 'NPSN-DROP-001',
        'education_level' => 'sd',
        'school_status' => 'public',
        'address' => 'Jl. Approved',
        'province' => 'DKI Jakarta',
        'city' => 'Jakarta',
        'contact_name' => 'Kontak',
        'contact_email' => 'approved@school.test',
        'status' => School::STATUS_APPROVED,
        'verified_at' => now(),
    ]);

    School::create([
        'name' => 'SD Pending',
        'slug' => 'sd-pending',
        'npsn' => 'NPSN-DROP-002',
        'education_level' => 'sd',
        'school_status' => 'public',
        'address' => 'Jl. Pending',
        'province' => 'DKI Jakarta',
        'city' => 'Jakarta',
        'contact_name' => 'Kontak',
        'contact_email' => 'pending@school.test',
        'status' => School::STATUS_PENDING,
    ]);

    SchoolClass::create([
        'school_id' => $approved->id,
        'school' => $approved->name,
        'name' => '5A',
        'grade' => '5',
        'is_active' => true,
    ]);
    SchoolClass::create([
        'school_id' => $approved->id,
        'school' => $approved->name,
        'name' => '5B',
        'grade' => '5',
        'is_active' => false,
    ]);

    $this->getJson('/api/public/schools')
        ->assertOk()
        ->assertJsonCount(1, 'schools')
        ->assertJsonPath('schools.0.id', $approved->id)
        ->assertJsonMissingPath('schools.0.contact_email');

    $this->getJson("/api/public/schools/{$approved->id}/classes")
        ->assertOk()
        ->assertJsonCount(1, 'classes')
        ->assertJsonPath('classes.0.name', '5A');
});

test('classroom activities are isolated by school id and class id', function () {
    $schoolA = School::create([
        'name' => 'SD A',
        'slug' => 'sd-a',
        'npsn' => 'NPSN-A',
        'education_level' => 'sd',
        'school_status' => 'public',
        'address' => 'Jl. A',
        'province' => 'DKI Jakarta',
        'city' => 'Jakarta',
        'contact_name' => 'Kontak A',
        'contact_email' => 'a@school.test',
        'status' => School::STATUS_APPROVED,
        'verified_at' => now(),
    ]);
    $schoolB = School::create([
        'name' => 'SD B',
        'slug' => 'sd-b',
        'npsn' => 'NPSN-B',
        'education_level' => 'sd',
        'school_status' => 'public',
        'address' => 'Jl. B',
        'province' => 'DKI Jakarta',
        'city' => 'Jakarta',
        'contact_name' => 'Kontak B',
        'contact_email' => 'b@school.test',
        'status' => School::STATUS_APPROVED,
        'verified_at' => now(),
    ]);

    $classA = SchoolClass::create([
        'school_id' => $schoolA->id,
        'school' => $schoolA->name,
        'name' => '5A',
        'grade' => '5',
        'is_active' => true,
    ]);
    $classB = SchoolClass::create([
        'school_id' => $schoolB->id,
        'school' => $schoolB->name,
        'name' => '5A',
        'grade' => '5',
        'is_active' => true,
    ]);

    $teacher = User::factory()->create([
        'school_id' => $schoolA->id,
        'school' => $schoolA->name,
        'approval_status' => 'approved',
    ]);
    $teacher->assignRole('teacher');

    $studentA = User::factory()->create([
        'school_id' => $schoolA->id,
        'school' => $schoolA->name,
        'class_id' => $classA->id,
        'approval_status' => 'approved',
    ]);
    $studentA->assignRole('student');

    $studentB = User::factory()->create([
        'school_id' => $schoolB->id,
        'school' => $schoolB->name,
        'class_id' => $classB->id,
        'approval_status' => 'approved',
    ]);
    $studentB->assignRole('student');

    Sanctum::actingAs($teacher);
    $teacherActivityId = $this->postJson('/api/activities', [
        'title' => 'Mengajar Matematika 5A',
        'activity_date' => '2026-09-06',
        'start_time' => '08:00',
        'end_time' => '09:00',
        'activity_kind' => 'teaching',
        'activity_type' => Activity::TYPE_CLASSROOM,
        'school_class_id' => $classA->id,
    ])
        ->assertCreated()
        ->assertJsonPath('activity.school_id', $schoolA->id)
        ->json('activity.id');

    Sanctum::actingAs($studentA);
    $this->getJson('/api/classroom/activities/available?date=2026-09-06')
        ->assertOk()
        ->assertJsonCount(1, 'activities')
        ->assertJsonPath('activities.0.id', $teacherActivityId);

    Sanctum::actingAs($studentB);
    $this->getJson('/api/classroom/activities/available?date=2026-09-06')
        ->assertOk()
        ->assertJsonCount(0, 'activities');
});
