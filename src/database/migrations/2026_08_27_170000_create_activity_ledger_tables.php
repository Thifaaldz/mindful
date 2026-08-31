<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('activities')) {
            Schema::create('activities', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
                $table->string('title');
                $table->string('category')->nullable();
                $table->date('activity_date');
                $table->timestamp('start_at')->nullable();
                $table->timestamp('end_at')->nullable();
                $table->decimal('planned_hours', 6, 2)->default(0);
                $table->decimal('actual_hours', 6, 2)->nullable();
                $table->decimal('intensity_factor', 4, 2)->default(1);
                $table->string('intensity_factor_version')->default('if-v2.2');
                $table->string('status')->default('planned');
                $table->timestamp('checkin_at')->nullable();
                $table->string('checkin_mood', 24)->nullable();
                $table->unsignedTinyInteger('checkin_intensity')->nullable();
                $table->text('checkin_trigger')->nullable();
                $table->timestamp('checkout_at')->nullable();
                $table->string('checkout_mood', 24)->nullable();
                $table->text('checkout_fact')->nullable();
                $table->text('checkout_feeling')->nullable();
                $table->text('checkout_pattern')->nullable();
                $table->text('checkout_plan')->nullable();
                $table->json('checkout_burnout_tags')->nullable();
                $table->json('checkout_auto_burnout_tags')->nullable();
                $table->string('checkout_analysis_source', 50)->nullable();
                $table->text('checkout_analysis_raw_response')->nullable();
                $table->string('checkout_mood_detected', 24)->nullable();
                $table->text('checkout_suggestion')->nullable();
                $table->boolean('checkout_crisis_flag')->default(false);
                $table->timestamps();

                $table->index(['user_id', 'activity_date', 'status'], 'act_user_date_status_idx');
                $table->index(['start_at', 'end_at'], 'act_start_end_idx');
            });
        }

        if (! Schema::hasTable('activity_events')) {
            Schema::create('activity_events', function (Blueprint $table) {
                $table->id();
                $table->foreignId('activity_id')->constrained('activities')->cascadeOnDelete();
                $table->string('event_type');
                $table->timestamp('occurred_at');
                $table->json('metadata')->nullable();
                $table->timestamps();

                $table->index(['activity_id', 'occurred_at'], 'act_events_activity_time_idx');
            });
        }

        if (! Schema::hasTable('burnout_analysis_snapshots')) {
            Schema::create('burnout_analysis_snapshots', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
                $table->string('source')->default('manual');
                $table->string('period_type');
                $table->date('period_start');
                $table->date('period_end');
                $table->boolean('data_sufficiency')->default(false);
                $table->unsignedInteger('activity_count')->default(0);
                $table->unsignedInteger('completed_activity_count')->default(0);
                $table->decimal('weighted_planned_hours', 8, 2)->default(0);
                $table->decimal('weighted_actual_hours', 8, 2)->default(0);
                $table->decimal('workload_score_raw', 8, 2)->default(0);
                $table->decimal('workload_variance_pct', 8, 2)->nullable();
                $table->decimal('journal_score', 8, 2)->default(0);
                $table->decimal('final_burnout_risk_score', 8, 2)->nullable();
                $table->string('category')->nullable();
                $table->json('dominant_factors')->nullable();
                $table->json('recommendation_codes')->nullable();
                $table->json('recommendation_summary')->nullable();
                $table->string('model_version')->default('rule-fastapi-mvp-v2.2');
                $table->string('scoring_version')->default('scoring-v2.2');
                $table->string('threshold_version')->default('threshold-v2.2');
                $table->json('payload')->nullable();
                $table->timestamps();

                $table->index(['user_id', 'period_type', 'period_start', 'period_end'], 'burnout_user_period_idx');
            });
        }

        if (! Schema::hasTable('burnout_self_reports')) {
            Schema::create('burnout_self_reports', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
                $table->unsignedTinyInteger('level');
                $table->timestamps();

                $table->index(['user_id', 'created_at'], 'burnout_self_reports_user_time_idx');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('burnout_self_reports');
        Schema::dropIfExists('burnout_analysis_snapshots');
        Schema::dropIfExists('activity_events');
        Schema::dropIfExists('activities');
    }
};
