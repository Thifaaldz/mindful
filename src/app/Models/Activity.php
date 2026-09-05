<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Activity extends Model
{
    use HasFactory;

    public const STATUS_PLANNED = 'planned';
    public const STATUS_CHECKED_IN = 'checked_in';
    public const STATUS_COMPLETED = 'completed';
    public const STATUS_CANCELLED = 'cancelled';
    public const TYPE_PERSONAL = 'personal';
    public const TYPE_CLASSROOM = 'classroom';
    public const TYPE_CLASSROOM_STUDENT = 'classroom_student';

    protected $fillable = [
        'user_id',
        'school_id',
        'title',
        'category',
        'activity_type',
        'activity_kind',
        'school_class_id',
        'teacher_activity_id',
        'joined_at',
        'activity_date',
        'start_at',
        'end_at',
        'planned_hours',
        'actual_hours',
        'intensity_factor',
        'intensity_factor_version',
        'status',
        'checkin_at',
        'checkin_mood',
        'checkin_intensity',
        'checkin_trigger',
        'checkout_at',
        'checkout_mood',
        'checkout_fact',
        'checkout_feeling',
        'checkout_pattern',
        'checkout_plan',
        'checkout_burnout_tags',
        'checkout_auto_burnout_tags',
        'checkout_analysis_source',
        'checkout_analysis_raw_response',
        'checkout_mood_detected',
        'checkout_suggestion',
        'checkout_crisis_flag',
    ];

    protected function casts(): array
    {
        return [
            'activity_date' => 'date:Y-m-d',
            'start_at' => 'datetime',
            'end_at' => 'datetime',
            'joined_at' => 'datetime',
            'planned_hours' => 'decimal:2',
            'actual_hours' => 'decimal:2',
            'intensity_factor' => 'decimal:2',
            'checkin_at' => 'datetime',
            'checkout_at' => 'datetime',
            'checkout_burnout_tags' => 'array',
            'checkout_auto_burnout_tags' => 'array',
            'checkout_crisis_flag' => 'boolean',
        ];
    }

    public function events(): HasMany
    {
        return $this->hasMany(ActivityEvent::class);
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function schoolModel(): BelongsTo
    {
        return $this->belongsTo(School::class, 'school_id');
    }

    public function schoolClass(): BelongsTo
    {
        return $this->belongsTo(SchoolClass::class, 'school_class_id');
    }

    public function teacherActivity(): BelongsTo
    {
        return $this->belongsTo(Activity::class, 'teacher_activity_id');
    }

    public function studentActivities(): HasMany
    {
        return $this->hasMany(Activity::class, 'teacher_activity_id');
    }

    public function appendEvent(string $eventType, array $metadata = []): ActivityEvent
    {
        return $this->events()->create([
            'event_type' => $eventType,
            'occurred_at' => now(),
            'metadata' => $metadata ?: null,
        ]);
    }
}
