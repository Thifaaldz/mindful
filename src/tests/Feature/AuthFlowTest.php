<?php

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

test('email registration starts from selected access role then completes profile later', function () {
    $response = $this->postJson('/api/register', [
        'email' => 'baru@mindfuledu.test',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'role' => 'teacher',
    ])
        ->assertCreated()
        ->assertJsonPath('user.email', 'baru@mindfuledu.test')
        ->assertJsonPath('user.role', 'teacher')
        ->assertJsonPath('user.profile_completed', false);

    $this->withToken($response->json('token'))
        ->putJson('/api/me/profile', [
            'name' => 'Guru Baru',
            'role' => 'teacher',
            'school' => 'SDN Mindful',
        ])
        ->assertOk()
        ->assertJsonPath('user.name', 'Guru Baru')
        ->assertJsonPath('user.role', 'teacher')
        ->assertJsonPath('user.profile_completed', true);

    expect(User::where('email', 'baru@mindfuledu.test')->first()->hasRole('teacher'))->toBeTrue();
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
