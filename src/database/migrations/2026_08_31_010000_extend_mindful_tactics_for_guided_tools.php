<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mindful_tactics', function (Blueprint $table) {
            if (! Schema::hasColumn('mindful_tactics', 'knowledge')) {
                $table->text('knowledge')->nullable()->after('description');
            }
            if (! Schema::hasColumn('mindful_tactics', 'duration_minutes')) {
                $table->unsignedSmallInteger('duration_minutes')->default(3)->after('knowledge');
            }
            if (! Schema::hasColumn('mindful_tactics', 'steps')) {
                $table->json('steps')->nullable()->after('duration_minutes');
            }
            if (! Schema::hasColumn('mindful_tactics', 'cues')) {
                $table->json('cues')->nullable()->after('steps');
            }
            if (! Schema::hasColumn('mindful_tactics', 'best_for')) {
                $table->json('best_for')->nullable()->after('cues');
            }
        });
    }

    public function down(): void
    {
        Schema::table('mindful_tactics', function (Blueprint $table) {
            foreach (['best_for', 'cues', 'steps', 'duration_minutes', 'knowledge'] as $column) {
                if (Schema::hasColumn('mindful_tactics', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
