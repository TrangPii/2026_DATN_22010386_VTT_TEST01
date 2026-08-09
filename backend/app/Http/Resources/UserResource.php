<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $providerProfile = $this->resource
            ->relationLoaded('providerProfile')
                ? $this->providerProfile
                : null;

        return [
            'id' => $this->id,

            'name' => $this->name,

            'email' => $this->email,

            'phone' => $this->phone,

            'avatar' => $this->avatar,

            'role' => $this->role,

            'status' => $this->status,

            'provider_status' =>
                $providerProfile?->verification_status,
                
            /*
             * null = chưa đăng ký Provider
             * PENDING = đang chờ Admin duyệt
             * APPROVED = đã có quyền Provider
             * REJECTED = hồ sơ bị từ chối
             */

            'can_use_provider_mode' =>
                $providerProfile !== null
                && $providerProfile->verification_status === 'APPROVED',

            'email_verified_at' =>
                $this->email_verified_at?->toISOString(),

            'last_login_at' =>
                $this->last_login_at?->toISOString(),

            'provider_profile' => $this->whenLoaded(
                'providerProfile',
                function (): ?array {
                    if ($this->providerProfile === null) {
                        return null;
                    }

                    return [
                        'id' =>
                            $this->providerProfile->id,

                        'business_name' =>
                            $this->providerProfile
                                ->business_name,

                        'description' =>
                            $this->providerProfile
                                ->description,

                        'address' =>
                            $this->providerProfile
                                ->address,

                        'experience_years' =>
                            $this->providerProfile
                                ->experience_years,

                        'average_rating' =>
                            $this->providerProfile
                                ->average_rating,

                        'total_reviews' =>
                            $this->providerProfile
                                ->total_reviews,

                        'verification_status' =>
                            $this->providerProfile
                                ->verification_status,

                        'verified_at' =>
                            $this->providerProfile
                                ->verified_at
                                ?->toISOString(),
                    ];
                }
            ),

            'created_at' =>
                $this->created_at?->toISOString(),

            'updated_at' =>
                $this->updated_at?->toISOString(),
        ];
    }
}