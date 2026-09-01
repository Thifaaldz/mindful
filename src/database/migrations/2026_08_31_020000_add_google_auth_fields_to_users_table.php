<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'google_id')) {
                $table->string('google_id')->nullable()->unique()->after('avatar_url');
            }

            if (! Schema::hasColumn('users', 'google_avatar_url')) {
                $table->string('google_avatar_url')->nullable()->after('google_id');
            }

            if (! Schema::hasColumn('users', 'profile_completed')) {
                $table->boolean('profile_completed')->default(true)->after('class_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'google_id')) {
                $table->dropUnique(['google_id']);
                $table->dropColumn('google_id');
            }

            foreach (['google_avatar_url', 'profile_completed'] as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
