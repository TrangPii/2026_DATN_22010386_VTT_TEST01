<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProviderProfile extends Model
{
    use HasFactory;

    public const VERIFICATION_PENDING = 'PENDING';

    public const VERIFICATION_APPROVED = 'APPROVED';

    public const VERIFICATION_REJECTED = 'REJECTED';

    public const STATUS_ACTIVE = 'ACTIVE';

    public const STATUS_LOCKED = 'LOCKED';

    protected $fillable = [
        'user_id',
        'business_name',
        'description',
        'address',
        'identity_number',
        'experience_years',
        'average_rating',
        'total_reviews',
        'verification_status',
        'provider_status',
        'verified_at',
    ];

    protected function casts(): array
    {
        return [
            'experience_years' => 'integer',
            'average_rating' => 'decimal:2',
            'total_reviews' => 'integer',
            'verified_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function isPending(): bool
    {
        return $this->verification_status ===
            self::VERIFICATION_PENDING;
    }

    public function isApproved(): bool
    {
        return $this->verification_status ===
            self::VERIFICATION_APPROVED;
    }

    public function isRejected(): bool
    {
        return $this->verification_status ===
            self::VERIFICATION_REJECTED;
    }

    public function isActive(): bool
    {
        return $this->isApproved()
            && $this->provider_status ===
                self::STATUS_ACTIVE;
    }

    public function isLocked(): bool
    {
        return $this->isApproved()
            && $this->provider_status ===
                self::STATUS_LOCKED;
    }
}