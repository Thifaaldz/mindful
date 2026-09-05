<?php

namespace Database\Seeders;

use App\Models\School;
use App\Models\SchoolClass;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $user = User::firstOrCreate(
            ['email' => 'admin@admin.com'],
            ['name' => 'Super Admin', 'password' => Hash::make('password')]
        );
        $user->assignRole('super_admin');

        $user = User::firstOrCreate(
            ['email' => 'user@admin.com'],
            ['name' => 'User Account', 'password' => Hash::make('password')]
        );
        $user->assignRole('user');

        $schools = [
            'SDN Contoh 1' => School::firstOrCreate(
                ['npsn' => 'DEMO-SDN-CONTOH-1'],
                [
                    'name' => 'SDN Contoh 1',
                    'slug' => School::makeUniqueSlug('SDN Contoh 1'),
                    'education_level' => 'sd',
                    'school_status' => 'public',
                    'address' => 'Jl. Pendidikan No. 1',
                    'province' => 'DKI Jakarta',
                    'city' => 'Jakarta',
                    'district' => 'Kebayoran',
                    'contact_name' => 'Kepala SDN Contoh 1',
                    'contact_position' => 'Kepala Sekolah',
                    'contact_email' => 'kontak.sdncontoh1@mindfuledu.test',
                    'contact_phone' => '080000000001',
                    'status' => School::STATUS_APPROVED,
                    'verified_at' => now(),
                    'verified_by' => $user->id,
                ]
            ),
            'SDN Contoh 2' => School::firstOrCreate(
                ['npsn' => 'DEMO-SDN-CONTOH-2'],
                [
                    'name' => 'SDN Contoh 2',
                    'slug' => School::makeUniqueSlug('SDN Contoh 2'),
                    'education_level' => 'sd',
                    'school_status' => 'public',
                    'address' => 'Jl. Pendidikan No. 2',
                    'province' => 'DKI Jakarta',
                    'city' => 'Jakarta',
                    'district' => 'Cilandak',
                    'contact_name' => 'Kepala SDN Contoh 2',
                    'contact_position' => 'Kepala Sekolah',
                    'contact_email' => 'kontak.sdncontoh2@mindfuledu.test',
                    'contact_phone' => '080000000002',
                    'status' => School::STATUS_APPROVED,
                    'verified_at' => now(),
                    'verified_by' => $user->id,
                ]
            ),
        ];

        $classes = [
            '5A' => SchoolClass::firstOrCreate(
                ['name' => '5A', 'school_id' => $schools['SDN Contoh 1']->id],
                ['school' => 'SDN Contoh 1', 'grade' => '5', 'is_active' => true]
            ),
            '5B' => SchoolClass::firstOrCreate(
                ['name' => '5B', 'school_id' => $schools['SDN Contoh 1']->id],
                ['school' => 'SDN Contoh 1', 'grade' => '5', 'is_active' => true]
            ),
            '6A' => SchoolClass::firstOrCreate(
                ['name' => '6A', 'school_id' => $schools['SDN Contoh 2']->id],
                ['school' => 'SDN Contoh 2', 'grade' => '6', 'is_active' => true]
            ),
        ];

        foreach ($schools as $school) {
            $schoolAdmin = User::updateOrCreate(
                ['email' => 'admin@'.$school->slug.'.test'],
                [
                    'name' => 'Admin '.$school->name,
                    'password' => Hash::make('password'),
                    'school_id' => $school->id,
                    'school' => $school->name,
                    'approval_status' => 'approved',
                    'approved_at' => now(),
                    'must_change_password' => false,
                    'profile_completed' => true,
                ]
            );
            $schoolAdmin->assignRole('school_admin');
        }

        $teachers = [
            [
                'email' => 'guru@mindfuledu.test',
                'name' => 'Bu Sari',
                'school' => 'SDN Contoh 1',
                'classes' => ['5A'],
            ],
            [
                'email' => 'guru.bima@mindfuledu.test',
                'name' => 'Pak Bima',
                'school' => 'SDN Contoh 1',
                'classes' => ['5B'],
            ],
            [
                'email' => 'guru.rani@mindfuledu.test',
                'name' => 'Bu Rani',
                'school' => 'SDN Contoh 2',
                'classes' => ['6A'],
            ],
        ];

        foreach ($teachers as $teacherData) {
            $teacher = User::updateOrCreate(
                ['email' => $teacherData['email']],
                [
                    'name' => $teacherData['name'],
                    'password' => Hash::make('password'),
                    'school_id' => $schools[$teacherData['school']]->id,
                    'school' => $teacherData['school'],
                    'approval_status' => 'approved',
                    'approved_at' => now(),
                    'profile_completed' => true,
                ]
            );
            $teacher->assignRole('teacher');
            $teacher->teachingClasses()->syncWithoutDetaching(
                collect($teacherData['classes'])->map(fn ($key) => $classes[$key]->id)->all()
            );
        }

        $students = [
            ['email' => 'siswa@mindfuledu.test', 'name' => 'Ani', 'school' => 'SDN Contoh 1', 'class' => '5A'],
            ['email' => 'budi@mindfuledu.test', 'name' => 'Budi', 'school' => 'SDN Contoh 1', 'class' => '5A'],
            ['email' => 'citra@mindfuledu.test', 'name' => 'Citra', 'school' => 'SDN Contoh 1', 'class' => '5A'],
            ['email' => 'dewi@mindfuledu.test', 'name' => 'Dewi', 'school' => 'SDN Contoh 1', 'class' => '5B'],
            ['email' => 'eko@mindfuledu.test', 'name' => 'Eko', 'school' => 'SDN Contoh 1', 'class' => '5B'],
            ['email' => 'farah@mindfuledu.test', 'name' => 'Farah', 'school' => 'SDN Contoh 2', 'class' => '6A'],
            ['email' => 'gilang@mindfuledu.test', 'name' => 'Gilang', 'school' => 'SDN Contoh 2', 'class' => '6A'],
        ];

        foreach ($students as $studentData) {
            $student = User::updateOrCreate(
                ['email' => $studentData['email']],
                [
                    'name' => $studentData['name'],
                    'password' => Hash::make('password'),
                    'school_id' => $schools[$studentData['school']]->id,
                    'school' => $studentData['school'],
                    'class_id' => $classes[$studentData['class']]->id,
                    'student_verification_code' => 'STU-'.strtoupper($studentData['class']).strtoupper(substr(md5($studentData['email']), 0, 4)),
                    'approval_status' => 'approved',
                    'approved_at' => now(),
                    'profile_completed' => true,
                ]
            );
            $student->assignRole('student');
        }

        $parent = User::updateOrCreate(
            ['email' => 'parent@mindfuledu.test'],
            [
                'name' => 'Orang Tua Ani',
                'password' => Hash::make('password'),
                'school_id' => $schools['SDN Contoh 1']->id,
                'school' => 'SDN Contoh 1',
                'approval_status' => 'approved',
                'profile_completed' => true,
            ]
        );
        $parent->assignRole('parent');
        $ani = User::where('email', 'siswa@mindfuledu.test')->first();
        if ($ani) {
            $parent->parentChildren()->syncWithoutDetaching([
                $ani->id => ['verified_at' => now()],
            ]);
        }
    }
}
