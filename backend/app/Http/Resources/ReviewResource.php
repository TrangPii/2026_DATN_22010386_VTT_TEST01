<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReviewResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'rating' => $this->rating,
            'comment' => $this->comment,
            'status' => $this->status,

            'customer' => $this->whenLoaded(
                'customer',
                fn () => [
                    'id' => $this->customer->id,
                    'name' => $this->customer->name,
                    'avatar' => $this->customer->avatar,
                ]
            ),

            'provider' => $this->whenLoaded(
                'provider',
                fn () => [
                    'id' => $this->provider->id,
                    'name' => $this->provider->name,
                ]
            ),

            'booking' => $this->whenLoaded(
                'booking',
                fn () => [
                    'id' => $this->booking->id,
                    'booking_code' => $this->booking->booking_code,
                    'service_name' => $this->booking->service_name,
                ]
            ),

            'created_at' =>
                $this->created_at?->toISOString(),

            'updated_at' =>
                $this->updated_at?->toISOString(),
        ];
    }
}