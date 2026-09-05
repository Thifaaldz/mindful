<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class School extends Model
{
    use HasFactory;

    public const STATUS_PENDING = 'pending';
    public const STATUS_APPROVED = 'approved';
    public const STATUS_REJECTED = 'rejected';
    public const STATUS_SUSPENDED = 'suspended';

    protected $fillable = [
        'name',
        'slug',
        'npsn',
        'education_level',
        'school_status',
        'address',
        'province',
        'city',
        'district',
        'contact_name',
        'contact_position',
        'contact_email',
        'contact_phone',
        'status',
        'verified_at',
        'verified_by',
        'rejected_at',
        'rejected_by',
        'rejection_reason',
    ];

    protected function casts(): array
    {
        return [
            'verified_at' => 'datetime',
            'rejected_at' => 'datetime',
        ];
    }

    public static function makeUniqueSlug(string $name, ?int $ignoreId = null): string
    {
        $base = Str::of($name)->lower()->replaceMatches('/[^a-z0-9]+/', '')->toString() ?: 'sekolah';
        $slug = $base;
        $suffix = 2;

        while (static::query()
            ->when($ignoreId, fn (Builder $query) => $query->whereKeyNot($ignoreId))
            ->where('slug', $slug)
            ->exists()) {
            $slug = $base.$suffix;
            $suffix++;
        }

        return $slug;
    }

    public function scopeApproved(Builder $query): Builder
    {
        return $query->where('status', self::STATUS_APPROVED);
    }

    public function classes(): HasMany
    {
        return $this->hasMany(SchoolClass::class);
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    public function schoolAdmins(): HasMany
    {
        return $this->users()->whereHas('roles', fn (Builder $query) => $query->where('name', 'school_admin'));
    }

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }

    public function rejector(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rejected_by');
    }
}
