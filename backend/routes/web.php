<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\ProviderController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\CategoryController;
use App\Http\Controllers\Admin\ServiceController;
use App\Http\Controllers\Admin\BookingController;

Route::get('/', function () {
    return view('welcome');
});

Route::prefix('admin')
    ->name('admin.')
    ->group(function (): void {

        // Admin guest

        Route::middleware('guest')
            ->group(function (): void {

                Route::get(
                    '/login',
                    [
                        AuthController::class,
                        'showLogin',
                    ]
                )
                    ->name('login');

                Route::post(
                    '/login',
                    [
                        AuthController::class,
                        'login',
                    ]
                )
                    ->name('login.submit');
            });

        // Auth Admin

        Route::middleware([
            'auth',
            'admin.web',
        ])
            ->group(function (): void {

                Route::get(
                    '/',
                    [
                        DashboardController::class,
                        'index',
                    ]
                )
                    ->name('dashboard');

                // Users
                Route::get(
                    '/users',
                    [
                        UserController::class,
                        'index',
                    ]
                )
                    ->name('users.index');

                Route::get(
                    '/users/{user}',
                    [
                        UserController::class,
                        'show',
                    ]
                )
                    ->name('users.show');

                Route::patch(
                    '/users/{user}/status',
                    [
                        UserController::class,
                        'updateStatus',
                    ]
                )
                    ->name('users.status');

                // Providers

                Route::get(
                    '/providers',
                    [
                        ProviderController::class,
                        'index',
                    ]
                )
                    ->name('providers.index');

                Route::get(
                    '/providers/{provider}',
                    [
                        ProviderController::class,
                        'show',
                    ]
                )
                    ->name('providers.show');

                Route::post(
                    '/providers/{provider}/approve',
                    [
                        ProviderController::class,
                        'approve',
                    ]
                )
                    ->name('providers.approve');

                Route::post(
                    '/providers/{provider}/reject',
                    [
                        ProviderController::class,
                        'reject',
                    ]
                )
                    ->name('providers.reject');

                // Categories
                Route::get(
    '/categories',
    [
        CategoryController::class,
        'index',
    ]
)
    ->name('categories.index');

Route::get(
    '/categories/create',
    [
        CategoryController::class,
        'create',
    ]
)
    ->name('categories.create');

Route::post(
    '/categories',
    [
        CategoryController::class,
        'store',
    ]
)
    ->name('categories.store');

Route::get(
    '/categories/{category}/edit',
    [
        CategoryController::class,
        'edit',
    ]
)
    ->name('categories.edit');

Route::put(
    '/categories/{category}',
    [
        CategoryController::class,
        'update',
    ]
)
    ->name('categories.update');

Route::patch(
    '/categories/{category}/status',
    [
        CategoryController::class,
        'updateStatus',
    ]
)
    ->name('categories.status');

                // Services
                Route::get(
    '/services',
    [
        ServiceController::class,
        'index',
    ]
)
    ->name('services.index');

Route::get(
    '/services/{service}',
    [
        ServiceController::class,
        'show',
    ]
)
    ->name('services.show');

Route::patch(
    '/services/{service}/status',
    [
        ServiceController::class,
        'updateStatus',
    ]
)
    ->name('services.status');

                // Bookings
                Route::get(
    '/bookings',
    [
        BookingController::class,
        'index',
    ]
)
    ->name('bookings.index');

Route::get(
    '/bookings/{booking}',
    [
        BookingController::class,
        'show',
    ]
)
    ->name('bookings.show');
                    
                Route::post(
                    '/logout',
                    [
                        AuthController::class,
                        'logout',
                    ]
                )
                    ->name('logout');
            });
    });