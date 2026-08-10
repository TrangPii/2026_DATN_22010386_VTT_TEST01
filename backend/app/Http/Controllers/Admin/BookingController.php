<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\View\View;

class BookingController extends Controller
{
    public function index(
        Request $request
    ): View {
        $validated = $request->validate([
            'search' => [
                'nullable',
                'string',
                'max:100',
            ],

            'status' => [
                'nullable',
                'in:PENDING,ACCEPTED,IN_PROGRESS,COMPLETED,REJECTED,CANCELLED',
            ],
        ]);

        $query = Booking::query()
            ->with([
                'customer',
                'provider.providerProfile',
                'service',
            ])
            ->latest();

        if (! empty($validated['search'])) {
            $search = trim(
                $validated['search']
            );

            $query->where(
                function ($query) use ($search): void {
                    $query
                        ->where(
                            'booking_code',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhere(
                            'service_name',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhere(
                            'customer_name',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhere(
                            'customer_phone',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhereHas(
                            'customer',
                            function ($customerQuery) use ($search): void {
                                $customerQuery->where(
                                    'email',
                                    'like',
                                    "%{$search}%"
                                );
                            }
                        )
                        ->orWhereHas(
                            'provider',
                            function ($providerQuery) use ($search): void {
                                $providerQuery
                                    ->where(
                                        'name',
                                        'like',
                                        "%{$search}%"
                                    )
                                    ->orWhereHas(
                                        'providerProfile',
                                        function ($profileQuery) use ($search): void {
                                            $profileQuery->where(
                                                'business_name',
                                                'like',
                                                "%{$search}%"
                                            );
                                        }
                                    );
                            }
                        );
                }
            );
        }

        if (! empty($validated['status'])) {
            $query->where(
                'status',
                $validated['status']
            );
        }

        $bookings = $query
            ->paginate(10)
            ->withQueryString();

        return view(
            'admin.bookings.booking_list',
            compact('bookings')
        );
    }

    public function show(
        Booking $booking
    ): View {
        $booking->load([
            'customer',
            'provider.providerProfile',
            'service.category',
            'statusHistories.changedByUser',
            'review',
        ]);

        return view(
            'admin.bookings.booking_detail',
            compact('booking')
        );
    }
}