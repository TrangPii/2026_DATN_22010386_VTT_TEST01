<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProviderProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProviderApplicationController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $profile = $request->user()
            ->providerProfile;

        return response()->json([
            'data' => [
                'application' => $profile,
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'business_name' => [
                'required',
                'string',
                'min:2',
                'max:150',
            ],

            'description' => [
                'nullable',
                'string',
                'max:2000',
            ],

            'address' => [
                'required',
                'string',
                'max:255',
            ],

            'identity_number' => [
                'required',
                'string',
                'max:50',
            ],

            'experience_years' => [
                'required',
                'integer',
                'min:0',
                'max:80',
            ],
        ]);

        $existing = $user->providerProfile;

        if (
            $existing &&
            $existing->verification_status === 'APPROVED'
        ) {
            return response()->json([
                'message' =>
                    'Tài khoản đã được xác minh là nhà cung cấp.',
            ], 422);
        }

        if (
            $existing &&
            $existing->verification_status === 'PENDING'
        ) {
            return response()->json([
                'message' =>
                    'Yêu cầu của bạn đang chờ Admin xác minh.',
            ], 422);
        }

        $profile = DB::transaction(
            function () use (
                $user,
                $validated,
                $existing
            ) {
                if ($existing) {
                    $existing->update([
                        ...$validated,
                        'verification_status' => 'PENDING',
                        'verified_at' => null,
                    ]);

                    return $existing->refresh();
                }

                return ProviderProfile::create([
                    'user_id' => $user->id,
                    ...$validated,
                    'verification_status' => 'PENDING',
                    'verified_at' => null,

                    'average_rating' => 0,
                    'total_reviews' => 0,
                ]);
            }
        );

        return response()->json([
            'message' =>
                'Đã gửi yêu cầu đăng ký nhà cung cấp.',

            'data' => [
                'application' => $profile,
            ],
        ], $existing ? 200 : 201);
    }
}