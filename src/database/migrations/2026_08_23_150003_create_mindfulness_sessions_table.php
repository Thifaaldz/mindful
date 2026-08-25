<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mindfulness_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('started_at');
            $table->timestamp('completed_at')->nullable();
            $table->unsignedInteger('duration_seconds')->default(0);
            $table->unsignedInteger('distraction_score')->default(0);
            $table->unsignedTinyInteger('calmness_before')->nullable();
            $table->unsignedTinyInteger('calmness_after')->nullable();
            $table->text('reflection')->nullable();
            $table->enum('status', ['in_progress', 'completed'])->default('in_progress');
            $table->timestamps();

            $table->index(['user_id', 'started_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mindfulness_sessions');
    }
};
