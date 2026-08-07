<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\BookingResource;
use App\Models\Booking;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminBookingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => [
                'nullable',
                'in:PENDING,ACCEPTED,IN_PROGRESS,COMPLETED,REJECTED,CANCELLED',
            ],

            'customer_id' => [
                'nullable',
                'integer',
                'exists:users,id',
            ],

            'provider_id' => [
                'nullable',
                'integer',
                'exists:users,id',
            ],

            'per_page' => [
                'nullable',
                'integer',
                'min:1',
                'max:100',
            ],
        ]);

        $query = Booking::query()
            ->with([
                'customer',
                'provider.providerProfile',
                'service',
            ])
            ->latest();

        foreach (
            [
                'status',
                'customer_id',
                'provider_id',
            ] as $field
        ) {
            if (! empty($validated[$field])) {
                $query->where(
                    $field,
                    $validated[$field]
                );
            }
        }

        $bookings = $query->paginate(
            $validated['per_page'] ?? 20
        );

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy danh sách booking thành công.',

            'data' => [
                'bookings' =>
                    BookingResource::collection(
                        $bookings->items()
                    ),

                'pagination' => [
                    'current_page' =>
                        $bookings->currentPage(),

                    'last_page' =>
                        $bookings->lastPage(),

                    'total' =>
                        $bookings->total(),
                ],
            ],
        ]);
    }

    public function show(
        Booking $booking
    ): JsonResponse {
        $booking->load([
            'customer',
            'provider.providerProfile',
            'service',
            'statusHistories.changedByUser',
            'review',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy chi tiết booking thành công.',

            'data' => [
                'booking' =>
                    new BookingResource($booking),
            ],
        ]);
    }
}