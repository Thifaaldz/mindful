<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('student_observations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('class_id')->constrained('classes')->cascadeOnDelete();
            $table->date('observed_on');
            $table->enum('perasaan', ['hijau', 'kuning', 'merah']);
            $table->enum('perilaku', ['hijau', 'kuning', 'merah']);
            $table->enum('tubuh', ['hijau', 'kuning', 'merah']);
            $table->enum('teman', ['hijau', 'kuning', 'merah']);
            $table->enum('belajar', ['hijau', 'kuning', 'merah']);
            $table->enum('status', ['hijau', 'kuning', 'merah']);
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->unique(['student_id', 'observed_on']);
            $table->index(['class_id', 'observed_on']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('student_observations');
    }
};
