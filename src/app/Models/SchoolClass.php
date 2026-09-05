<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class SchoolClass extends Model
{
    use HasFactory;

    protected $table = 'classes';

    protected $fillable = [
        'name',
        'grade',
        'school',
        'school_id',
        'academic_year',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    public function schoolModel(): BelongsTo
    {
        return $this->belongsTo(School::class, 'school_id');
    }

    public function students(): HasMany
    {
        return $this->hasMany(User::class, 'class_id');
    }

    public function teachers(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'class_teacher', 'class_id', 'teacher_id');
    }

    public function observations(): HasMany
    {
        return $this->hasMany(StudentObservation::class, 'class_id');
    }
}
