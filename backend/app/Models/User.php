<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;
    use HasFactory;
    use Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'email_verified_at',
        'password',
        'avatar',
        'role',
        'status',
        'last_login_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Tự động sinh mã người dùng.
     *
     * Admin:
     * SS0000
     *
     * User thông thường:
     * SS0001 -> SS9999
     */
    protected static function booted(): void
    {
        static::creating(function (User $user): void {
            /*
             * Admin luôn sử dụng mã cố định SS0000.
             */
            if ($user->role === 'ADMIN') {
                $user->user_code = 'SS0000';

                return;
            }

            /*
             * Lấy mã user lớn nhất hiện tại.
             *
             * lockForUpdate() có tác dụng khi User được tạo
             * bên trong transaction, như AuthController hiện tại.
             */
            $lastUserCode = static::query()
                ->whereNotNull('user_code')
                ->where('user_code', '!=', 'SS0000')
                ->orderByDesc('user_code')
                ->lockForUpdate()
                ->value('user_code');

            $nextNumber = $lastUserCode !== null
                ? ((int) substr($lastUserCode, 2)) + 1
                : 1;

            if ($nextNumber > 9999) {
                throw new \RuntimeException(
                    'Đã đạt giới hạn mã người dùng SS9999.'
                );
            }

            $user->user_code = sprintf(
                'SS%04d',
                $nextNumber
            );
        });
    }

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'last_login_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function canUseProviderMode(): bool
    {
        return $this->providerProfile !== null
            && $this->providerProfile->verification_status === 'APPROVED';
    }

    public function providerProfile(): HasOne
    {
        return $this->hasOne(ProviderProfile::class);
    }

    public function services(): HasMany
    {
        return $this->hasMany(
            Service::class,
            'provider_id'
        );
    }

    public function customerBookings(): HasMany
    {
        return $this->hasMany(
            Booking::class,
            'customer_id'
        );
    }

    public function providerBookings(): HasMany
    {
        return $this->hasMany(
            Booking::class,
            'provider_id'
        );
    }

    public function reviewsWritten(): HasMany
    {
        return $this->hasMany(
            Review::class,
            'customer_id'
        );
    }

    public function reviewsReceived(): HasMany
    {
        return $this->hasMany(
            Review::class,
            'provider_id'
        );
    }

    public function bookingStatusChanges(): HasMany
    {
        return $this->hasMany(
            BookingStatusHistory::class,
            'changed_by'
        );
    }
}
