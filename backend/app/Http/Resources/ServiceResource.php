<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class ServiceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'slug' => $this->slug,
            'description' => $this->description,

            'price' => $this->price,
            'price_unit' => $this->price_unit,
            'estimated_duration_minutes' =>
                $this->estimated_duration_minutes,

            'image' => $this->image ? $request->getSchemeAndHttpHost(). Storage::url($this->image): null,
            'status' => $this->status,

            'category' => $this->whenLoaded(
                'category',
                fn () => [
                    'id' => $this->category->id,
                    'name' => $this->category->name,
                    'slug' => $this->category->slug,
                ]
            ),

            'provider' => $this->whenLoaded(
                'provider',
                fn () => [
                    'id' => $this->provider->id,
                    'name' => $this->provider->name,
                    'avatar' => $this->provider->avatar,

                    'provider_profile' =>
                        $this->provider->providerProfile
                            ? [
                                'business_name' =>
                                    $this->provider
                                        ->providerProfile
                                        ->business_name,

                                'average_rating' =>
                                    $this->provider
                                        ->providerProfile
                                        ->average_rating,

                                'total_reviews' =>
                                    $this->provider
                                        ->providerProfile
                                        ->total_reviews,

                                'verification_status' =>
                                    $this->provider
                                        ->providerProfile
                                        ->verification_status,
                            ]
                            : null,
                ]
            ),

            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}