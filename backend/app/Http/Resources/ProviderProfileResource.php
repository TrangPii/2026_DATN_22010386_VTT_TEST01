<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProviderProfileResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,

            'business_name' => $this->business_name,
            'description' => $this->description,
            'address' => $this->address,

            'experience_years' =>
                $this->experience_years,

            'average_rating' =>
                $this->average_rating,

            'total_reviews' =>
                $this->total_reviews,

            'verification_status' =>
                $this->verification_status,

            'verified_at' =>
                $this->verified_at?->toISOString(),

            'user' => $this->whenLoaded(
                'user',
                function () use ($request): array {
                $isOwner =
                    $request->user()?->id ===
                    $this->user->id;

                return [
                    'id' => $this->user->id,
                    'name' => $this->user->name,
                    'avatar' => $this->user->avatar,
                    'status' => $this->user->status,

                    'email' =>
                        $isOwner
                        ? $this->user->email
                        : null,

                    'phone' =>
                        $isOwner
                        ? $this->user->phone
                        : null,
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