<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('schools')) {
            Schema::create('schools', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('slug')->unique();
                $table->string('npsn')->unique();
                $table->string('education_level')->nullable();
                $table->string('school_status')->nullable();
                $table->text('address')->nullable();
                $table->string('province')->nullable();
                $table->string('city')->nullable();
                $table->string('district')->nullable();
                $table->string('contact_name');
                $table->string('contact_position')->nullable();
                $table->string('contact_email');
                $table->string('contact_phone')->nullable();
                $table->string('status')->default('pending');
                $table->timestamp('verified_at')->nullable();
                $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
                $table->timestamp('rejected_at')->nullable();
                $table->foreignId('rejected_by')->nullable()->constrained('users')->nullOnDelete();
                $table->text('rejection_reason')->nullable();
                $table->timestamps();

                $table->index(['status', 'name']);
            });
        }

        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'school_id')) {
                $table->foreignId('school_id')->nullable()->after('school')->constrained('schools')->nullOnDelete();
            }
            if (! Schema::hasColumn('users', 'approval_status')) {
                $table->string('approval_status', 24)->default('approved')->after('student_verification_code');
            }
            if (! Schema::hasColumn('users', 'approved_at')) {
                $table->timestamp('approved_at')->nullable()->after('approval_status');
            }
            if (! Schema::hasColumn('users', 'approved_by')) {
                $table->foreignId('approved_by')->nullable()->after('approved_at')->constrained('users')->nullOnDelete();
            }
            if (! Schema::hasColumn('users', 'rejected_at')) {
                $table->timestamp('rejected_at')->nullable()->after('approved_by');
            }
            if (! Schema::hasColumn('users', 'rejected_by')) {
                $table->foreignId('rejected_by')->nullable()->after('rejected_at')->constrained('users')->nullOnDelete();
            }
            if (! Schema::hasColumn('users', 'rejection_reason')) {
                $table->text('rejection_reason')->nullable()->after('rejected_by');
            }
            if (! Schema::hasColumn('users', 'must_change_password')) {
                $table->boolean('must_change_password')->default(false)->after('rejection_reason');
            }
        });

        Schema::table('classes', function (Blueprint $table) {
            if (! Schema::hasColumn('classes', 'school_id')) {
                $table->foreignId('school_id')->nullable()->after('school')->constrained('schools')->nullOnDelete();
            }
            if (! Schema::hasColumn('classes', 'academic_year')) {
                $table->string('academic_year', 20)->nullable()->after('grade');
            }
            if (! Schema::hasColumn('classes', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('academic_year');
            }
        });

        Schema::table('activities', function (Blueprint $table) {
            if (! Schema::hasColumn('activities', 'school_id')) {
                $table->foreignId('school_id')->nullable()->after('user_id')->constrained('schools')->nullOnDelete();
            }
        });

        $this->backfillSchools();
    }

    public function down(): void
    {
        Schema::table('activities', function (Blueprint $table) {
            if (Schema::hasColumn('activities', 'school_id')) {
                $table->dropConstrainedForeignId('school_id');
            }
        });

        Schema::table('classes', function (Blueprint $table) {
            foreach (['is_active', 'academic_year'] as $column) {
                if (Schema::hasColumn('classes', $column)) {
                    $table->dropColumn($column);
                }
            }
            if (Schema::hasColumn('classes', 'school_id')) {
                $table->dropConstrainedForeignId('school_id');
            }
        });

        Schema::table('users', function (Blueprint $table) {
            foreach (['must_change_password', 'rejection_reason'] as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
            foreach (['rejected_by', 'approved_by', 'school_id'] as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropConstrainedForeignId($column);
                }
            }
            foreach (['rejected_at', 'approved_at', 'approval_status'] as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
        });

        Schema::dropIfExists('schools');
    }

    private function backfillSchools(): void
    {
        $names = collect(DB::table('users')->whereNotNull('school')->pluck('school'))
            ->merge(DB::table('classes')->whereNotNull('school')->pluck('school'))
            ->map(fn ($name) => trim((string) $name))
            ->filter()
            ->unique(fn ($name) => strtolower($name));

        foreach ($names as $name) {
            $slug = $this->uniqueSlug($name);
            $schoolId = DB::table('schools')->whereRaw('LOWER(name) = ?', [strtolower($name)])->value('id');

            if (! $schoolId) {
                $schoolId = DB::table('schools')->insertGetId([
                    'name' => $name,
                    'slug' => $slug,
                    'npsn' => 'LEGACY-'.$slug,
                    'education_level' => null,
                    'school_status' => null,
                    'address' => 'Data sekolah legacy dari sistem sebelumnya.',
                    'province' => null,
                    'city' => null,
                    'district' => null,
                    'contact_name' => 'Admin '.$name,
                    'contact_position' => 'Administrator',
                    'contact_email' => 'admin+'.$slug.'@mindfuledu.test',
                    'contact_phone' => null,
                    'status' => 'approved',
                    'verified_at' => now(),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            DB::table('users')
                ->whereRaw('LOWER(TRIM(school)) = ?', [strtolower($name)])
                ->whereNull('school_id')
                ->update(['school_id' => $schoolId]);

            DB::table('classes')
                ->whereRaw('LOWER(TRIM(school)) = ?', [strtolower($name)])
                ->whereNull('school_id')
                ->update(['school_id' => $schoolId]);
        }

        DB::table('activities')
            ->whereNull('school_id')
            ->orderBy('id')
            ->select(['id', 'user_id'])
            ->chunk(200, function ($activities): void {
                $schoolIds = DB::table('users')
                    ->whereIn('id', $activities->pluck('user_id')->filter()->unique()->values())
                    ->whereNotNull('school_id')
                    ->pluck('school_id', 'id');

                foreach ($activities as $activity) {
                    $schoolId = $schoolIds[$activity->user_id] ?? null;

                    if ($schoolId) {
                        DB::table('activities')
                            ->where('id', $activity->id)
                            ->update(['school_id' => $schoolId]);
                    }
                }
            });
    }

    private function uniqueSlug(string $name): string
    {
        $base = Str::of($name)->lower()->replaceMatches('/[^a-z0-9]+/', '')->toString() ?: 'sekolah';
        $slug = $base;
        $suffix = 2;

        while (DB::table('schools')->where('slug', $slug)->exists()) {
            $slug = $base.$suffix;
            $suffix++;
        }

        return $slug;
    }
};
