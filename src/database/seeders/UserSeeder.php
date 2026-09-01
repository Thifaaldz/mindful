<?php

namespace Database\Seeders;

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

        $classes = [
            '5A' => SchoolClass::firstOrCreate(['name' => '5A', 'school' => 'SDN Contoh 1'], ['grade' => '5']),
            '5B' => SchoolClass::firstOrCreate(['name' => '5B', 'school' => 'SDN Contoh 1'], ['grade' => '5']),
            '6A' => SchoolClass::firstOrCreate(['name' => '6A', 'school' => 'SDN Contoh 2'], ['grade' => '6']),
        ];

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
                    'school' => $teacherData['school'],
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
                    'school' => $studentData['school'],
                    'class_id' => $classes[$studentData['class']]->id,
                    'student_verification_code' => 'STU-'.strtoupper($studentData['class']).strtoupper(substr(md5($studentData['email']), 0, 4)),
                ]
            );
            $student->assignRole('student');
        }

        $parent = User::updateOrCreate(
            ['email' => 'parent@mindfuledu.test'],
            [
                'name' => 'Orang Tua Ani',
                'password' => Hash::make('password'),
                'school' => 'SDN Contoh 1',
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
