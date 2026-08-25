<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('reminder_enabled')->default(false);
            $table->time('reminder_time')->nullable();
            $table->string('reminder_channel')->default('push');
            $table->string('reminder_timezone')->nullable();
            $table->timestamp('last_reminder_sent_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'reminder_enabled',
                'reminder_time',
                'reminder_channel',
                'reminder_timezone',
                'last_reminder_sent_at',
            ]);
        });
    }
};
