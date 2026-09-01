<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('classes', function (Blueprint $table) {
            if (! Schema::hasColumn('classes', 'school')) {
                $table->string('school')->nullable()->after('grade');
            }
        });

        if (Schema::hasColumn('classes', 'school') && ! $this->hasIndex('classes', 'classes_school_name_idx')) {
            Schema::table('classes', function (Blueprint $table) {
                $table->index(['school', 'name'], 'classes_school_name_idx');
            });
        }

        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'student_verification_code')) {
                $table->string('student_verification_code', 24)->nullable()->unique()->after('class_id');
            }
        });

        Schema::table('activities', function (Blueprint $table) {
            if (! Schema::hasColumn('activities', 'activity_type')) {
                $table->string('activity_type', 32)->default('personal')->after('category');
            }
            if (! Schema::hasColumn('activities', 'school_class_id')) {
                $table->foreignId('school_class_id')->nullable()->after('activity_type')
                    ->constrained('classes')->nullOnDelete();
            }
            if (! Schema::hasColumn('activities', 'teacher_activity_id')) {
                $table->foreignId('teacher_activity_id')->nullable()->after('school_class_id')
                    ->constrained('activities')->cascadeOnDelete();
            }
            if (! Schema::hasColumn('activities', 'joined_at')) {
                $table->timestamp('joined_at')->nullable()->after('teacher_activity_id');
            }
        });

        if (! $this->hasIndex('activities', 'act_classroom_lookup_idx')) {
            Schema::table('activities', function (Blueprint $table) {
                $table->index(['activity_type', 'school_class_id', 'activity_date'], 'act_classroom_lookup_idx');
            });
        }

        if (! $this->hasIndex('activities', 'act_teacher_student_idx')) {
            Schema::table('activities', function (Blueprint $table) {
                $table->index(['teacher_activity_id', 'user_id'], 'act_teacher_student_idx');
            });
        }

        if (Schema::hasTable('parent_student_links')) {
            return;
        }

        Schema::create('parent_student_links', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parent_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();

            $table->unique(['parent_id', 'student_id'], 'parent_student_unique');
            $table->index(['student_id', 'parent_id'], 'student_parent_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('parent_student_links');

        Schema::table('activities', function (Blueprint $table) {
            if ($this->hasIndex('activities', 'act_classroom_lookup_idx')) {
                $table->dropIndex('act_classroom_lookup_idx');
            }
            if ($this->hasIndex('activities', 'act_teacher_student_idx')) {
                $table->dropIndex('act_teacher_student_idx');
            }
            if (Schema::hasColumn('activities', 'joined_at')) {
                $table->dropColumn('joined_at');
            }
            if (Schema::hasColumn('activities', 'teacher_activity_id')) {
                $table->dropConstrainedForeignId('teacher_activity_id');
            }
            if (Schema::hasColumn('activities', 'school_class_id')) {
                $table->dropConstrainedForeignId('school_class_id');
            }
            if (Schema::hasColumn('activities', 'activity_type')) {
                $table->dropColumn('activity_type');
            }
        });

        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'student_verification_code')) {
                $table->dropColumn('student_verification_code');
            }
        });

        Schema::table('classes', function (Blueprint $table) {
            if (Schema::hasColumn('classes', 'school')) {
                if ($this->hasIndex('classes', 'classes_school_name_idx')) {
                    $table->dropIndex('classes_school_name_idx');
                }
                $table->dropColumn('school');
            }
        });
    }

    private function hasIndex(string $table, string $indexName): bool
    {
        try {
            return collect(Schema::getIndexes($table))
                ->contains(fn (array $index) => ($index['name'] ?? null) === $indexName);
        } catch (\Throwable) {
            return false;
        }
    }
};
