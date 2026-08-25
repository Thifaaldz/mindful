<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QuestionnaireResponse extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'respondent_profile',
        'answers',
        'overall_score',
        'percentage_score',
        'comment',
        'submitted_at',
    ];

    protected function casts(): array
    {
        return [
            'respondent_profile' => 'array',
            'answers' => 'array',
            'percentage_score' => 'decimal:2',
            'submitted_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
