<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mindfulness_sessions', function (Blueprint $table) {
            $table->text('body_note')->nullable()->after('reflection');
            $table->text('helpful_note')->nullable()->after('body_note');
            $table->json('logbook_answers')->nullable()->after('helpful_note');
        });
    }

    public function down(): void
    {
        Schema::table('mindfulness_sessions', function (Blueprint $table) {
            $table->dropColumn(['body_note', 'helpful_note', 'logbook_answers']);
        });
    }
};
