<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MindfulnessSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'started_at',
        'completed_at',
        'duration_seconds',
        'distraction_score',
        'calmness_before',
        'calmness_after',
        'reflection',
        'body_note',
        'helpful_note',
        'logbook_answers',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
            'logbook_answers' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
