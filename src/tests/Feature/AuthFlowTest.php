<?php

use App\Models\School;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Spatie\Permission\Models\Role;

uses(RefreshDatabase::class);

beforeEach(function () {
    Role::create(['name' => 'teacher']);
    Role::create(['name' => 'student']);
    Role::create(['name' => 'parent']);
});

test('email registration uses approved school and waits for school admin approval', function () {
    $school = School::create([
        'name' => 'SDN Mindful',
        'slug' => 'sdn-mindful',
        'npsn' => 'TEST-001',
        'education_level' => 'sd',
        'school_status' => 'public',
        'address' => 'Jl. Mindful',
        'province' => 'DKI Jakarta',
        'city' => 'Jakarta',
        'contact_name' => 'Admin Sekolah',
        'contact_email' => 'admin.sekolah@mindfuledu.test',
        'status' => School::STATUS_APPROVED,
        'verified_at' => now(),
    ]);

    $this->postJson('/api/register', [
        'name' => 'Guru Baru',
        'email' => 'baru@mindfuledu.test',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'role' => 'teacher',
        'school_id' => $school->id,
    ])
        ->assertStatus(202)
        ->assertJsonPath('user.email', 'baru@mindfuledu.test')
        ->assertJsonPath('user.role', 'teacher')
        ->assertJsonPath('user.school_id', $school->id)
        ->assertJsonPath('user.approval_status', 'pending')
        ->assertJsonMissingPath('token');

    $this->postJson('/api/login', [
        'email' => 'baru@mindfuledu.test',
        'password' => 'password123',
        'role' => 'teacher',
    ])->assertForbidden();

    $user = User::where('email', 'baru@mindfuledu.test')->first();
    $user->forceFill([
        'approval_status' => 'approved',
        'approved_at' => now(),
    ])->save();

    $this->postJson('/api/login', [
        'email' => 'baru@mindfuledu.test',
        'password' => 'password123',
        'role' => 'teacher',
    ])
        ->assertOk()
        ->assertJsonStructure(['token']);

    expect($user->hasRole('teacher'))->toBeTrue();
});

test('google login creates account from verified id token', function () {
    config(['services.google.client_id' => 'google-client-id.test']);

    Http::fake([
        'oauth2.googleapis.com/tokeninfo*' => Http::response([
            'aud' => 'google-client-id.test',
            'sub' => 'google-user-123',
            'email' => 'google@mindfuledu.test',
            'email_verified' => 'true',
            'name' => 'Google User',
            'picture' => 'https://lh3.googleusercontent.com/avatar.png',
        ]),
    ]);

    $this->postJson('/api/auth/google', [
        'id_token' => 'valid-google-id-token',
        'role' => 'student',
    ])
        ->assertOk()
        ->assertJsonPath('user.email', 'google@mindfuledu.test')
        ->assertJsonPath('user.name', 'Google User')
        ->assertJsonPath('user.role', 'student')
        ->assertJsonPath('user.profile_completed', false)
        ->assertJsonPath('user.avatar_url', 'https://lh3.googleusercontent.com/avatar.png')
        ->assertJsonStructure(['token']);

    $user = User::where('email', 'google@mindfuledu.test')->first();

    expect($user->google_id)->toBe('google-user-123')
        ->and($user->email_verified_at)->not->toBeNull();
});

test('same account login revokes previous device session and records history', function () {
    $user = User::factory()->create([
        'email' => 'guru@mindfuledu.test',
    ]);
    $user->assignRole('teacher');

    $firstLogin = $this->postJson('/api/login', [
        'email' => 'guru@mindfuledu.test',
        'password' => 'password',
        'role' => 'teacher',
        'device_id' => 'device-a',
        'device_name' => 'Samsung A55',
        'device_brand' => 'Samsung',
        'device_model' => 'SM-A556E',
        'device_platform' => 'android',
    ])->assertOk();

    $secondLogin = $this->postJson('/api/login', [
        'email' => 'guru@mindfuledu.test',
        'password' => 'password',
        'role' => 'teacher',
        'device_id' => 'device-b',
        'device_name' => 'OPPO Reno',
        'device_brand' => 'OPPO',
        'device_model' => 'CPH2607',
        'device_platform' => 'android',
    ])->assertOk();

    expect($firstLogin->json('token'))->not->toBe($secondLogin->json('token'))
        ->and($user->tokens()->count())->toBe(1)
        ->and($user->loginHistories()->count())->toBe(2)
        ->and($user->loginHistories()->latest('logged_in_at')->first()->device_name)->toBe('OPPO Reno')
        ->and($user->loginHistories()->latest('logged_in_at')->first()->location)->toBe('Jakarta')
        ->and($user->loginHistories()->latest('logged_in_at')->first()->revoked_previous_sessions)->toBeTrue();

    $this->withToken($firstLogin->json('token'))
        ->getJson('/api/me')
        ->assertUnauthorized();

    $this->withToken($secondLogin->json('token'))
        ->getJson('/api/me')
        ->assertOk()
        ->assertJsonPath('user.email', 'guru@mindfuledu.test')
        ->assertJsonPath('user.latest_login.device_name', 'OPPO Reno')
        ->assertJsonPath('user.latest_login.location', 'Jakarta')
        ->assertJsonCount(2, 'user.login_histories');
});
