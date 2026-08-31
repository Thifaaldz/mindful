<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['nullable', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'role' => ['nullable', Rule::in(['teacher', 'student'])],
            'school' => ['nullable', 'string', 'max:255'],
            'class_id' => ['nullable', 'integer', 'exists:classes,id'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $role = $data['role'] ?? null;

        $user = User::create([
            'name' => $data['name'] ?? Str::of($data['email'])->before('@')->replace('.', ' ')->title()->toString(),
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'school' => $data['school'] ?? null,
            'class_id' => $role === 'student' ? ($data['class_id'] ?? null) : null,
            'profile_completed' => filled($role) && filled($data['name'] ?? null),
        ]);

        if ($role) {
            $user->assignRole($role);
        }

        $token = $user->createToken('mindfuledu-mobile')->plainTextToken;

        return response()->json([
            'user' => $this->formatUser($user),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $user = User::where('email', $request->string('email'))->first();

        if (! $user || ! Hash::check($request->string('password'), $user->password)) {
            return response()->json(['message' => 'Email atau password salah'], 401);
        }

        $token = $user->createToken('mindfuledu-mobile')->plainTextToken;

        return response()->json([
            'user' => $this->formatUser($user),
            'token' => $token,
        ]);
    }

    public function google(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_token' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $payload = $this->verifyGoogleIdToken($validator->validated()['id_token']);

        if (! $payload) {
            return response()->json(['message' => 'Login Google tidak valid'], 401);
        }

        $email = $payload['email'] ?? null;

        if (! $email) {
            return response()->json(['message' => 'Akun Google tidak memiliki email'], 422);
        }

        $emailVerified = filter_var($payload['email_verified'] ?? false, FILTER_VALIDATE_BOOL);
        $user = User::firstOrNew(['email' => $email]);

        if (! $user->exists) {
            $user->name = $payload['name']
                ?? Str::of($email)->before('@')->replace('.', ' ')->title()->toString();
            $user->password = Hash::make(Str::random(40));
            $user->profile_completed = false;
        }

        $user->google_id = $payload['sub'] ?? $user->google_id;
        $user->google_avatar_url = $payload['picture'] ?? $user->google_avatar_url;

        if ($emailVerified && ! $user->email_verified_at) {
            $user->email_verified_at = now();
        }

        $user->save();

        $token = $user->createToken('mindfuledu-mobile')->plainTextToken;

        return response()->json([
            'user' => $this->formatUser($user),
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil logout']);
    }

    public function me(Request $request)
    {
        return response()->json(['user' => $this->formatUser($request->user())]);
    }

    public function updateProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:255'],
            'role' => ['required', Rule::in(['teacher', 'student'])],
            'school' => ['nullable', 'string', 'max:255'],
            'class_id' => ['nullable', 'integer', 'exists:classes,id'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $user = $request->user();

        $user->forceFill([
            'name' => $data['name'],
            'school' => $data['school'] ?? null,
            'class_id' => $data['role'] === 'student' ? ($data['class_id'] ?? null) : null,
            'profile_completed' => true,
        ])->save();

        $user->syncRoles([$data['role']]);

        return response()->json(['user' => $this->formatUser($user->refresh())]);
    }

    private function verifyGoogleIdToken(string $idToken): ?array
    {
        try {
            $response = Http::timeout(5)->get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $idToken,
            ]);
        } catch (\Throwable) {
            return null;
        }

        if (! $response->ok()) {
            return null;
        }

        $payload = $response->json();
        $clientId = config('services.google.client_id');

        if ($clientId && ($payload['aud'] ?? null) !== $clientId) {
            return null;
        }

        return is_array($payload) ? $payload : null;
    }

    private function formatUser(User $user): array
    {
        $user->loadMissing('roles', 'schoolClass');

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'school' => $user->school,
            'avatar_url' => $user->getFilamentAvatarUrl(),
            'role' => $user->roles->first()?->name,
            'profile_completed' => (bool) $user->profile_completed,
            'class' => $user->schoolClass ? [
                'id' => $user->schoolClass->id,
                'name' => $user->schoolClass->name,
            ] : null,
        ];
    }
}
