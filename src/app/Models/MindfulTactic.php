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
        'sort_order',
    ];

    public function bookmarkedBy(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'tactic_bookmarks');
    }
}
