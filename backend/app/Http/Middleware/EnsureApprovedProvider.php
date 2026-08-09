<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureApprovedProvider
{
    public function handle(
        Request $request,
        Closure $next
    ): Response {
        $user = $request->user();

        if (! $user || $user->status !== 'ACTIVE') {
            return response()->json([
                'message' => 'Tài khoản không khả dụng.',
            ], 403);
        }

        $profile = $user->providerProfile;

        if (
            ! $profile ||
            $profile->verification_status !== 'APPROVED'
        ) {
            return response()->json([
                'message' => 'Bạn chưa được cấp quyền nhà cung cấp.',
            ], 403);
        }

        return $next($request);
    }
}