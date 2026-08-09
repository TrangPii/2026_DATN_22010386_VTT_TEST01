<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\ProviderProfile;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class AdminDashboardController extends Controller
{
    public function index(): JsonResponse
    {
        $data = [
            'users' => [
                'total' => User::count(),

                'customers' => User::where(
                    'role',
                    'CUSTOMER'
                )->count(),

                'providers' => ProviderProfile::where(
                    'verification_status',
                    'APPROVED'
                )->count(),

                'locked' => User::where(
                    'status',
                    'LOCKED'
                )->count(),
            ],

            'providers' => [
                'pending' => ProviderProfile::where(
                    'verification_status',
                    'PENDING'
                )->count(),

                'approved' => ProviderProfile::where(
                    'verification_status',
                    'APPROVED'
                )->count(),

                'rejected' => ProviderProfile::where(
                    'verification_status',
                    'REJECTED'
                )->count(),
            ],

            'services' => [
                'total' => Service::count(),

                'active' => Service::where(
                    'status',
                    'ACTIVE'
                )->count(),

                'inactive' => Service::where(
                    'status',
                    'INACTIVE'
                )->count(),

                'categories' =>
                    ServiceCategory::count(),
            ],

            'bookings' => [
                'total' => Booking::count(),

                'pending' => Booking::where(
                    'status',
                    'PENDING'
                )->count(),

                'in_progress' => Booking::where(
                    'status',
                    'IN_PROGRESS'
                )->count(),

                'completed' => Booking::where(
                    'status',
                    'COMPLETED'
                )->count(),

                'cancelled' => Booking::where(
                    'status',
                    'CANCELLED'
                )->count(),
            ],

            'revenue' => [
                'completed_booking_value' =>
                    Booking::where(
                        'status',
                        'COMPLETED'
                    )->sum('total_amount'),
            ],
        ];

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy dữ liệu dashboard thành công.',
            'data' => $data,
        ]);
    }
}