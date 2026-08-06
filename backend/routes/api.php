<?php

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Route;

Route::get('/health', function (): JsonResponse {
    return response()->json([
        'success' => true,
        'message' => 'Smart Service Hub API is running',
        'data' => [
            'application' => config('app.name'),
            'environment' => app()->environment(),
            'timestamp' => now()->toDateTimeString(),
        ],
    ]);
});