<?php

namespace App\Http\Middleware;

use App\Models\ProviderProfile;
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

        /*
         * User bị khóa thì mất toàn bộ quyền Customer và Provider.
         */
        if ($user->status !== 'ACTIVE') {
            return response()->json([
                'success' => false,
                'message' =>
                    'Tài khoản không khả dụng.',
            ], 403);
        }

        $user->loadMissing(
            'providerProfile'
        );

        $profile = $user->providerProfile;

        /*
         * Chưa có hồ sơ hoặc chưa APPROVED.
         */
        if (
            $profile === null
            || $profile->verification_status !==
                ProviderProfile::VERIFICATION_APPROVED
        ) {
            return response()->json([
                'success' => false,
                'message' =>
                    'Bạn chưa được cấp quyền Nhà cung cấp.',
            ], 403);
        }

        /*
         * Provider đã được APPROVED nhưng quyền hoạt động Provider đang bị khóa.
         *
         * User vẫn có thể sử dụng Customer mode.
         */
        if (
            $profile->provider_status !==
            ProviderProfile::STATUS_ACTIVE
        ) {
            return response()->json([
                'success' => false,
                'message' =>
                    'Quyền Nhà cung cấp hiện đang bị khóa.',
            ], 403);
        }

        return $next($request);
    }
}