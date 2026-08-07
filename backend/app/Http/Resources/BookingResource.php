<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BookingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'booking_code' => $this->booking_code,

            'service_name' => $this->service_name,
            'unit_price' => $this->unit_price,
            'quantity' => $this->quantity,
            'total_amount' => $this->total_amount,

            'booking_date' =>
                $this->booking_date?->format('Y-m-d'),

            'booking_time' => $this->booking_time,

            'customer_name' => $this->customer_name,
            'customer_phone' => $this->customer_phone,
            'service_address' => $this->service_address,
            'note' => $this->note,

            'status' => $this->status,

            'rejection_reason' => $this->rejection_reason,
            'cancellation_reason' =>
                $this->cancellation_reason,

            'accepted_at' =>
                $this->accepted_at?->toISOString(),

            'started_at' =>
                $this->started_at?->toISOString(),

            'completed_at' =>
                $this->completed_at?->toISOString(),

            'cancelled_at' =>
                $this->cancelled_at?->toISOString(),

            'customer' => $this->whenLoaded(
                'customer',
                fn () => [
                    'id' => $this->customer->id,
                    'name' => $this->customer->name,
                    'phone' => $this->customer->phone,
                ]
            ),

            'provider' => $this->whenLoaded(
                'provider',
                fn () => [
                    'id' => $this->provider->id,
                    'name' => $this->provider->name,
                    'phone' => $this->provider->phone,

                    'business_name' =>
                        $this->provider->providerProfile
                            ?->business_name,
                ]
            ),

            'service' => $this->whenLoaded(
                'service',
                fn () => [
                    'id' => $this->service->id,
                    'name' => $this->service->name,
                    'image' => $this->service->image,
                ]
            ),

            'status_histories' =>
                BookingStatusHistoryResource::collection(
                    $this->whenLoaded('statusHistories')
                ),
            
            'review' => $this->whenLoaded(
                'review',
                fn () => $this->review
                    ? new ReviewResource($this->review)
                    : null
            ),

            'created_at' =>
                $this->created_at?->toISOString(),

            'updated_at' =>
                $this->updated_at?->toISOString(),
        ];
    }
}