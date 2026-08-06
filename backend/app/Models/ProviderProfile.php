<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProviderProfile extends Model
{
    use HasFactory;

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
}