<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SchoolClass;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
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
            'role' => ['required', Rule::in(['teacher', 'student', 'parent'])],
            'school' => ['nullable', 'string', 'max:255', 'required_if:role,parent'],
            'class_id' => ['nullable', 'integer', 'exists:classes,id'],
            'class_name' => ['nullable', 'string', 'max:80'],
            'student_verification_code' => ['nullable', 'string', 'max:24', 'required_if:role,parent'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $role = $data['role'];

        [$user, $student] = DB::transaction(function () use ($data, $role) {
            $student = $role === 'parent'
                ? $this->studentForParentCode($data['student_verification_code'] ?? null, $data['school'] ?? null)
                : null;

            $user = User::create([
                'name' => $data['name'] ?? Str::of($data['email'])->before('@')->replace('.', ' ')->title()->toString(),
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'school' => $data['school'] ?? null,
                'class_id' => $role === 'student' ? $this->resolveStudentClassId($data) : null,
                'student_verification_code' => $role === 'student' ? $this->newStudentVerificationCode() : null,
                'profile_completed' => filled($role) && filled($data['name'] ?? null),
            ]);

            $user->assignRole($role);

            if ($student) {
                $user->parentChildren()->syncWithoutDetaching([
                    $student->id => ['verified_at' => now()],
                ]);
            }

            return [$user, $student];
        });

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
            'role' => ['required', Rule::in(['teacher', 'student', 'parent'])],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json(['message' => 'Email atau password salah'], 401);
        }

        $this->ensureRoleAccess($user, $data['role']);

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
            'role' => ['required', Rule::in(['teacher', 'student', 'parent'])],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $payload = $this->verifyGoogleIdToken($data['id_token']);

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
        } else {
            $this->ensureRoleAccess($user, $data['role']);
        }

        $user->google_id = $payload['sub'] ?? $user->google_id;
        $user->google_avatar_url = $payload['picture'] ?? $user->google_avatar_url;

        if ($emailVerified && ! $user->email_verified_at) {
            $user->email_verified_at = now();
        }

        $user->save();

        $this->ensureRoleAccess($user, $data['role']);

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
            'role' => ['required', Rule::in(['teacher', 'student', 'parent'])],
            'school' => ['nullable', 'string', 'max:255', 'required_if:role,parent'],
            'class_id' => ['nullable', 'integer', 'exists:classes,id'],
            'class_name' => ['nullable', 'string', 'max:80'],
            'student_verification_code' => ['nullable', 'string', 'max:24', 'required_if:role,parent'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $user = $request->user();

        $this->ensureRoleAccess($user, $data['role']);

        DB::transaction(function () use ($user, $data) {
            $student = $data['role'] === 'parent'
                ? $this->studentForParentCode($data['student_verification_code'] ?? null, $data['school'] ?? null)
                : null;

            $user->forceFill([
                'name' => $data['name'],
                'school' => $data['school'] ?? null,
                'class_id' => $data['role'] === 'student' ? $this->resolveStudentClassId($data) : null,
                'student_verification_code' => $data['role'] === 'student'
                    ? ($user->student_verification_code ?: $this->newStudentVerificationCode())
                    : null,
                'profile_completed' => true,
            ])->save();

            $user->syncRoles([$data['role']]);

            if ($student) {
                $user->parentChildren()->syncWithoutDetaching([
                    $student->id => ['verified_at' => now()],
                ]);
            }
        });

        return response()->json(['user' => $this->formatUser($user->refresh())]);
    }

    public function updateAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'avatar' => ['required', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $user = $request->user();
        $oldAvatar = $user->avatar_url;
        $path = $request->file('avatar')->store('avatars', 'public');

        $user->forceFill(['avatar_url' => $path])->save();

        if ($oldAvatar) {
            Storage::disk('public')->delete($oldAvatar);
        }

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
        $user->loadMissing('roles', 'schoolClass', 'parentChildren');

        if ($user->isStudent() && ! $user->student_verification_code) {
            $user->forceFill(['student_verification_code' => $this->newStudentVerificationCode()])->save();
        }

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'school' => $user->school,
            'avatar_url' => $this->avatarUrl($user),
            'role' => $user->roles->first()?->name,
            'profile_completed' => (bool) $user->profile_completed,
            'student_verification_code' => $user->isStudent() ? $user->student_verification_code : null,
            'class' => $user->schoolClass ? [
                'id' => $user->schoolClass->id,
                'name' => $user->schoolClass->name,
            ] : null,
            'children' => $user->isParent()
                ? $user->parentChildren->map(fn (User $student) => [
                    'id' => $student->id,
                    'name' => $student->name,
                    'school' => $student->school,
                    'class' => $student->schoolClass ? [
                        'id' => $student->schoolClass->id,
                        'name' => $student->schoolClass->name,
                    ] : null,
                ])->values()
                : [],
        ];
    }

    private function ensureRoleAccess(User $user, string $role): void
    {
        $user->loadMissing('roles');

        if ($user->roles->isEmpty()) {
            $user->assignRole($role);
            $user->load('roles');

            return;
        }

        abort_unless(
            $user->hasRole($role),
            403,
            'Akun ini terdaftar sebagai '.$this->roleLabel($user->roles->first()?->name).', silakan masuk melalui akses yang sesuai.'
        );
    }

    private function avatarUrl(User $user): ?string
    {
        if ($user->avatar_url) {
            return url(Storage::url($user->avatar_url));
        }

        return $user->getFilamentAvatarUrl();
    }

    private function roleLabel(?string $role): string
    {
        return match ($role) {
            'teacher' => 'Guru',
            'student' => 'Siswa',
            'parent' => 'Orang Tua',
            default => 'pengguna lain',
        };
    }

    private function resolveStudentClassId(array $data): ?int
    {
        if (filled($data['class_id'] ?? null)) {
            $schoolClass = SchoolClass::find($data['class_id']);
            abort_if(
                $schoolClass && filled($data['school'] ?? null) && filled($schoolClass->school)
                    && strcasecmp(trim((string) $schoolClass->school), trim((string) $data['school'])) !== 0,
                422,
                'Kelas harus berada di sekolah yang sama.'
            );

            return (int) $data['class_id'];
        }

        $className = strtoupper(trim((string) ($data['class_name'] ?? '')));
        if ($className === '') {
            return null;
        }

        abort_if(blank($data['school'] ?? null), 422, 'Sekolah wajib diisi untuk menyimpan kelas siswa.');

        $schoolClass = SchoolClass::firstOrCreate(
            ['name' => $className, 'school' => trim((string) $data['school'])],
            ['grade' => $this->gradeFromClassName($className)]
        );

        return $schoolClass->id;
    }

    private function gradeFromClassName(string $className): ?string
    {
        preg_match('/\d+/', $className, $matches);

        return $matches[0] ?? null;
    }

    private function studentForParentCode(?string $code, ?string $school): User
    {
        $normalizedCode = strtoupper(trim((string) $code));
        $student = User::role('student')
            ->where('student_verification_code', $normalizedCode)
            ->first();

        abort_if(! $student, 422, 'Kode verifikasi siswa tidak ditemukan.');
        abort_if(
            filled($school) && filled($student->school) && strcasecmp(trim((string) $school), trim((string) $student->school)) !== 0,
            422,
            'Sekolah parent harus sama dengan sekolah siswa.'
        );

        return $student;
    }

    private function newStudentVerificationCode(): string
    {
        do {
            $code = 'STU-'.Str::upper(Str::random(8));
        } while (User::where('student_verification_code', $code)->exists());

        return $code;
    }
}
