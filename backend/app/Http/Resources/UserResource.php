<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'avatar' => $this->avatar,
            'role' => $this->role,
            'status' => $this->status,

            'email_verified_at' => $this->email_verified_at?->toISOString(),
            'last_login_at' => $this->last_login_at?->toISOString(),

            'provider_profile' => $this->whenLoaded(
                'providerProfile',
                function (): ?array {
                    if ($this->providerProfile === null) {
                        return null;
                    }

                    return [
                        'id' => $this->providerProfile->id,
                        'business_name' =>
                            $this->providerProfile->business_name,
                        'description' =>
                            $this->providerProfile->description,
                        'address' => $this->providerProfile->address,
                        'experience_years' =>
                            $this->providerProfile->experience_years,
                        'average_rating' =>
                            $this->providerProfile->average_rating,
                        'total_reviews' =>
                            $this->providerProfile->total_reviews,
                        'verification_status' =>
                            $this->providerProfile->verification_status,
                    ];
                }
            ),

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}