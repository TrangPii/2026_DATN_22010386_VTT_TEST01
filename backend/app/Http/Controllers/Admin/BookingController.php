<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\ProviderProfile;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\View\View;

class BookingController extends Controller
{
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'booking_code' => [
                'nullable',
                'string',
                'max:50',
            ],
            'user_code' => [
                'nullable',
                'string',
                'max:20',
            ],
            'service_name' => [
                'nullable',
                'string',
                'max:100',
            ],
            'provider_id' => [
                'nullable',
                'integer',
                'exists:users,id',
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
            ->orderByDesc('created_at')
            ->orderByDesc('id');

        if (! empty($validated['booking_code'])) {
            $bookingCode = trim($validated['booking_code']);

            $query->where(
                'booking_code',
                'like',
                "%{$bookingCode}%"
            );
        }

        if (! empty($validated['user_code'])) {
            $userCode = trim($validated['user_code']);

            $query->whereHas(
                'customer',
                function ($customerQuery) use ($userCode): void {
                    $customerQuery->where(
                        'user_code',
                        'like',
                        "%{$userCode}%"
                    );
                }
            );
        }

        if (! empty($validated['service_name'])) {
            $serviceName = trim($validated['service_name']);

            $query->where(
                'service_name',
                'like',
                "%{$serviceName}%"
            );
        }

        if (! empty($validated['provider_id'])) {
            $query->where(
                'provider_id',
                $validated['provider_id']
            );
        }

        if (! empty($validated['status'])) {
            $query->where(
                'status',
                $validated['status']
            );
        }

        $bookings = $query
            ->paginate(6)
            ->withQueryString();

        $providers = User::query()
            ->with('providerProfile')
            ->whereHas(
                'providerProfile',
                function ($profileQuery): void {
                    $profileQuery->where(
                        'verification_status',
                        ProviderProfile::VERIFICATION_APPROVED
                    );
                }
            )
            ->orderBy('name')
            ->get();

        return view(
            'admin.bookings.booking_list',
            compact(
                'bookings',
                'providers'
            )
        );
    }

    public function show(Booking $booking): View
    {
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