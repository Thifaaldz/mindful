<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('user_login_histories')) {
            return;
        }

        Schema::create('user_login_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('role', 32)->nullable();
            $table->string('device_id')->nullable();
            $table->string('device_name')->nullable();
            $table->string('device_brand')->nullable();
            $table->string('device_model')->nullable();
            $table->string('device_platform', 64)->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->string('location')->default('Jakarta');
            $table->timestamp('logged_in_at');
            $table->boolean('revoked_previous_sessions')->default(false);
            $table->timestamps();

            $table->index(['user_id', 'logged_in_at'], 'login_history_user_time_idx');
            $table->index(['device_id', 'logged_in_at'], 'login_history_device_time_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_login_histories');
    }
};
