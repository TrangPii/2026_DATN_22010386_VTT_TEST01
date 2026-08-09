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

        if ($user === null) {
            return response()->json([
                'success' => false,
                'message' => 'Bạn chưa đăng nhập.',
            ], 401);
        }

        if ($user->status !== 'ACTIVE') {
            return response()->json([
                'success' => false,
                'message' => 'Tài khoản không khả dụng.',
            ], 403);
        }

        $user->loadMissing('providerProfile');

        if (
            $user->providerProfile === null ||
            $user->providerProfile->verification_status !== 'APPROVED'
        ) {
            return response()->json([
                'success' => false,
                'message' =>
                    'Bạn chưa được cấp quyền Nhà cung cấp.',
            ], 403);
        }

        return $next($request);
    }
}