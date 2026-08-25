<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'role' => ['required', Rule::in(['teacher', 'student'])],
            'school' => ['nullable', 'string', 'max:255'],
            'class_id' => ['nullable', 'integer', 'exists:classes,id'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'school' => $data['school'] ?? null,
            'class_id' => $data['role'] === 'student' ? ($data['class_id'] ?? null) : null,
        ]);

        $user->assignRole($data['role']);

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

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil logout']);
    }

    public function me(Request $request)
    {
        return response()->json(['user' => $this->formatUser($request->user())]);
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
            'class' => $user->schoolClass ? [
                'id' => $user->schoolClass->id,
                'name' => $user->schoolClass->name,
            ] : null,
        ];
    }
}
