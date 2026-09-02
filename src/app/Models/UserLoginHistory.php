<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserLoginHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'role',
        'device_id',
        'device_name',
        'device_brand',
        'device_model',
        'device_platform',
        'ip_address',
        'location',
        'logged_in_at',
        'revoked_previous_sessions',
    ];

    protected function casts(): array
    {
        return [
            'logged_in_at' => 'datetime',
            'revoked_previous_sessions' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
