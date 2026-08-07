<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BookingStatusHistoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'old_status' => $this->old_status,
            'new_status' => $this->new_status,
            'note' => $this->note,

            'changed_by' => $this->whenLoaded(
                'changedByUser',
                fn () => $this->changedByUser
                    ? [
                        'id' => $this->changedByUser->id,
                        'name' => $this->changedByUser->name,
                        'role' => $this->changedByUser->role,
                    ]
                    : null
            ),

            'created_at' =>
                $this->created_at?->toISOString(),
        ];
    }
}