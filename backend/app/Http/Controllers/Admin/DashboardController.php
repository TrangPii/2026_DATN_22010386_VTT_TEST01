<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\ProviderProfile;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\View\View;

class DashboardController extends Controller
{
    public function index(): View
    {
        $stats = [
            'users' => User::count(),

            'customers' => User::where(
                'role',
                'CUSTOMER'
            )->count(),

            'providers' => ProviderProfile::where(
                'verification_status',
                'APPROVED'
            )->count(),

            'pending_providers' =>
                ProviderProfile::where(
                    'verification_status',
                    'PENDING'
                )->count(),

            'categories' =>
                ServiceCategory::count(),

            'services' =>
                Service::count(),

            'bookings' =>
                Booking::count(),

            'pending_bookings' =>
                Booking::where(
                    'status',
                    'PENDING'
                )->count(),

            'completed_bookings' =>
                Booking::where(
                    'status',
                    'COMPLETED'
                )->count(),

            'completed_value' =>
                Booking::where(
                    'status',
                    'COMPLETED'
                )->sum('total_amount'),
        ];

        $recentBookings = Booking::query()
            ->with([
                'customer',
                'provider',
            ])
            ->latest()
            ->limit(5)
            ->get();

        return view(
            'admin.dashboard',
            compact(
                'stats',
                'recentBookings'
            )
        );
    }
}