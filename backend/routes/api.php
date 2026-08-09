<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ServiceCategoryController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\ProviderBookingController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\ProviderApplicationController;
use App\Http\Controllers\Api\ProviderServiceController;
use App\Http\Controllers\Api\ProviderProfileController;
use App\Http\Controllers\Api\Admin\AdminBookingController;
use App\Http\Controllers\Api\Admin\AdminCategoryController;
use App\Http\Controllers\Api\Admin\AdminDashboardController;
use App\Http\Controllers\Api\Admin\AdminProviderController;
use App\Http\Controllers\Api\Admin\AdminServiceController;
use App\Http\Controllers\Api\Admin\AdminUserController;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Route;

Route::get('/health', function (): JsonResponse {
    return response()->json([
        'success' => true,
        'message' => 'Smart Service Hub API is running.',
        'data' => [
            'application' => config('app.name'),
            'environment' => app()->environment(),
            'timestamp' => now()->toISOString(),
        ],
    ]);
});

Route::prefix('auth')->group(function (): void {
    Route::middleware('throttle:10,1')->group(function (): void {
        #throttle:10,1 = max khoảng 10 requests/phút
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
    });

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/logout-all', [AuthController::class, 'logoutAll']);
    });
});

// Public categories
Route::get(
    '/categories',
    [ServiceCategoryController::class, 'index']
);

Route::get(
    '/categories/{category}',
    [ServiceCategoryController::class, 'show']
);

Route::get(
    '/categories/{category}/services',
    [ServiceCategoryController::class, 'services']
);

// Public services
Route::get(
    '/services',
    [ServiceController::class, 'index']
);

Route::get(
    '/services/{service}',
    [ServiceController::class, 'show']
);

// Customer Booking
Route::middleware('auth:sanctum')->group(
    function (): void {

        Route::get(
            '/bookings',
            [BookingController::class, 'index']
        );

        Route::post(
            '/bookings',
            [BookingController::class, 'store']
        );

        Route::get(
            '/bookings/{booking}',
            [BookingController::class, 'show']
        );

        Route::post(
            '/bookings/{booking}/cancel',
            [BookingController::class, 'cancel']
        );
    }
);

// Public review
Route::middleware('auth:sanctum')->group(
    function (): void {
        Route::post(
            '/bookings/{booking}/review',
            [ReviewController::class, 'store']
        );
    }
);

Route::get(
    '/providers/{providerId}/reviews',
    [ReviewController::class, 'providerReviews']
);

// Provider application
Route::middleware('auth:sanctum')
    ->group(function () {

        Route::get(
            '/provider-application',
            [ProviderApplicationController::class, 'show']
        );

        Route::post(
            '/provider-application',
            [ProviderApplicationController::class, 'store']
        );
    });

// Approved Provider
Route::middleware([
    'auth:sanctum',
    'provider.approved',
])
    ->prefix('provider')
    ->group(function (): void {

        // Provider bookings
        Route::get(
            '/bookings',
            [
                ProviderBookingController::class,
                'index',
            ]
        );

        Route::get(
            '/bookings/{booking}',
            [
                ProviderBookingController::class,
                'show',
            ]
        );

        Route::post(
            '/bookings/{booking}/accept',
            [
                ProviderBookingController::class,
                'accept',
            ]
        );

        Route::post(
            '/bookings/{booking}/reject',
            [
                ProviderBookingController::class,
                'reject',
            ]
        );

        Route::post(
            '/bookings/{booking}/start',
            [
                ProviderBookingController::class,
                'start',
            ]
        );

        Route::post(
            '/bookings/{booking}/complete',
            [
                ProviderBookingController::class,
                'complete',
            ]
        );


        // Provider services
        Route::get(
            '/services',
            [
                ProviderServiceController::class,
                'index',
            ]
        );

        Route::post(
            '/services',
            [
                ProviderServiceController::class,
                'store',
            ]
        );

        Route::get(
            '/services/{service}',
            [
                ProviderServiceController::class,
                'show',
            ]
        );

        Route::put(
            '/services/{service}',
            [
                ProviderServiceController::class,
                'update',
            ]
        );

        Route::patch(
            '/services/{service}/status',
            [
                ProviderServiceController::class,
                'updateStatus',
            ]
        );


        // Provider profile
        Route::get(
            '/profile',
            [
                ProviderProfileController::class,
                'me',
            ]
        );

        Route::put(
            '/profile',
            [
                ProviderProfileController::class,
                'update',
            ]
        );
    });

// Public provider profile
Route::get(
    '/providers/{provider}',
    [ProviderProfileController::class, 'show']
);

//Admin
Route::middleware([
    'auth:sanctum',
    'admin',
])
    ->prefix('admin')
    ->group(function (): void {

        // Dashboard
        Route::get(
            '/dashboard',
            [
                AdminDashboardController::class,
                'index',
            ]
        );

        // Users
        Route::get(
            '/users',
            [
                AdminUserController::class,
                'index',
            ]
        );

        Route::get(
            '/users/{user}',
            [
                AdminUserController::class,
                'show',
            ]
        );

        Route::patch(
            '/users/{user}/status',
            [
                AdminUserController::class,
                'updateStatus',
            ]
        );

        // Providers
        Route::get(
            '/providers',
            [
                AdminProviderController::class,
                'index',
            ]
        );

        Route::post(
            '/providers/{profile}/approve',
            [
                AdminProviderController::class,
                'approve',
            ]
        );

        Route::post(
            '/providers/{profile}/reject',
            [
                AdminProviderController::class,
                'reject',
            ]
        );

        // Categories
        Route::get(
            '/categories',
            [
                AdminCategoryController::class,
                'index',
            ]
        );

        Route::post(
            '/categories',
            [
                AdminCategoryController::class,
                'store',
            ]
        );

        Route::put(
            '/categories/{category}',
            [
                AdminCategoryController::class,
                'update',
            ]
        );

        Route::patch(
            '/categories/{category}/status',
            [
                AdminCategoryController::class,
                'updateStatus',
            ]
        );

        // Services
        Route::get(
            '/services',
            [
                AdminServiceController::class,
                'index',
            ]
        );

        Route::patch(
            '/services/{service}/status',
            [
                AdminServiceController::class,
                'updateStatus',
            ]
        );

        // Bookings
        Route::get(
            '/bookings',
            [
                AdminBookingController::class,
                'index',
            ]
        );

        Route::get(
            '/bookings/{booking}',
            [
                AdminBookingController::class,
                'show',
            ]
        );
    });