<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BurnoutAnalysisSnapshot extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'source',
        'period_type',
        'period_start',
        'period_end',
        'data_sufficiency',
        'activity_count',
        'completed_activity_count',
        'weighted_planned_hours',
        'weighted_actual_hours',
        'workload_score_raw',
        'workload_variance_pct',
        'journal_score',
        'final_burnout_risk_score',
        'category',
        'dominant_factors',
        'recommendation_codes',
        'recommendation_summary',
        'model_version',
        'scoring_version',
        'threshold_version',
        'payload',
    ];

    protected function casts(): array
    {
        return [
            'period_start' => 'date',
            'period_end' => 'date',
            'data_sufficiency' => 'boolean',
            'weighted_planned_hours' => 'decimal:2',
            'weighted_actual_hours' => 'decimal:2',
            'workload_score_raw' => 'decimal:2',
            'workload_variance_pct' => 'decimal:2',
            'journal_score' => 'decimal:2',
            'final_burnout_risk_score' => 'decimal:2',
            'dominant_factors' => 'array',
            'recommendation_codes' => 'array',
            'recommendation_summary' => 'array',
            'payload' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
