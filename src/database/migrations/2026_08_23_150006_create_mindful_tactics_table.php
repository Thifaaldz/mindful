<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mindful_tactics', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('category')->nullable();
            $table->text('description');
            $table->unsignedInteger('sort_order')->default(0);
            $table->timestamps();
        });

        Schema::create('tactic_bookmarks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('mindful_tactic_id')->constrained('mindful_tactics')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['user_id', 'mindful_tactic_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tactic_bookmarks');
        Schema::dropIfExists('mindful_tactics');
    }
};
