<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\UserController;

Route::get('/', function () {
    return view('welcome');
});

Route::prefix('admin')
    ->name('admin.')
    ->group(function (): void {

        Route::middleware('guest')
            ->group(function (): void {

                Route::get(
                    '/login',
                    [AuthController::class, 'showLogin']
                )
                    ->name('login');

                Route::post(
                    '/login',
                    [AuthController::class, 'login']
                )
                    ->name('login.submit');
            });

        Route::middleware([
            'auth',
            'admin.web',
        ])
            ->group(function (): void {

                Route::get(
                    '/',
                    [DashboardController::class, 'index']
                )
                    ->name('dashboard');

                Route::get(
                    '/users',
                    [UserController::class, 'index']
                )
                    ->name('users.index');

                Route::get(
                    '/users/{user}',
                    [UserController::class, 'show']
                )
                    ->name('users.show');

                Route::patch(
                    '/users/{user}/status',
                    [UserController::class, 'updateStatus']
                )
                    ->name('users.status');

                Route::post(
                    '/logout',
                    [AuthController::class, 'logout']
                )
                    ->name('logout');
            });
    });
