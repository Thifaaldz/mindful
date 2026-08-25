<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasAvatar;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable implements FilamentUser, HasAvatar
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'avatar_url',
        'name',
        'email',
        'password',
        'school',
        'class_id',
        'reminder_enabled',
        'reminder_time',
        'reminder_channel',
        'reminder_timezone',
        'last_reminder_sent_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'reminder_enabled' => 'boolean',
            'last_reminder_sent_at' => 'datetime',
        ];
    }

    public function getFilamentAvatarUrl(): ?string
    {
        if ($this->avatar_url) {
            return asset('storage/' . $this->avatar_url);
        } else {
            $hash = md5(strtolower(trim($this->email)));

            return 'https://www.gravatar.com/avatar/' . $hash . '?d=mp&r=g&s=250';
        }
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return $this->hasRole(['super_admin', 'admin']);
    }

    /**
     * The class a student belongs to.
     */
    public function schoolClass(): BelongsTo
    {
        return $this->belongsTo(SchoolClass::class, 'class_id');
    }

    /**
     * Classes a teacher is assigned to teach.
     */
    public function teachingClasses(): BelongsToMany
    {
        return $this->belongsToMany(SchoolClass::class, 'class_teacher', 'teacher_id', 'class_id');
    }

    public function mindfulnessSessions(): HasMany
    {
        return $this->hasMany(MindfulnessSession::class);
    }

    /**
     * Observations made by this user acting as a teacher.
     */
    public function observationsMade(): HasMany
    {
        return $this->hasMany(StudentObservation::class, 'teacher_id');
    }

    /**
     * Observations recorded about this user acting as a student.
     */
    public function observationsReceived(): HasMany
    {
        return $this->hasMany(StudentObservation::class, 'student_id');
    }

    public function questionnaireResponses(): HasMany
    {
        return $this->hasMany(QuestionnaireResponse::class);
    }

    public function badges(): BelongsToMany
    {
        return $this->belongsToMany(Badge::class, 'user_badges')
            ->withPivot('earned_at')
            ->withTimestamps();
    }

    public function bookmarkedTactics(): BelongsToMany
    {
        return $this->belongsToMany(MindfulTactic::class, 'tactic_bookmarks');
    }

    public function isTeacher(): bool
    {
        return $this->hasRole('teacher');
    }

    public function isStudent(): bool
    {
        return $this->hasRole('student');
    }
}
