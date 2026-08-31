<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class MindfulTactic extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'category',
        'description',
        'knowledge',
        'duration_minutes',
        'steps',
        'cues',
        'best_for',
        'sort_order',
    ];

    protected $casts = [
        'duration_minutes' => 'integer',
        'steps' => 'array',
        'cues' => 'array',
        'best_for' => 'array',
    ];

    public function bookmarkedBy(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'tactic_bookmarks');
    }
}
