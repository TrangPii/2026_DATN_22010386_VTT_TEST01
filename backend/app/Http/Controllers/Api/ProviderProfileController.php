<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Provider\UpdateProviderProfileRequest;
use App\Http\Resources\ProviderProfileResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProviderProfileController extends Controller
{
    //  Lấy hồ sơ Provider của user đang đăng nhập
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        $profile = $user
            ->providerProfile()
            ->with('user')
            ->first();

        if ($profile === null) {
            return response()->json([
                'success' => false,
                'message' =>
                    'Hồ sơ nhà cung cấp chưa tồn tại.',
            ], 404);
        }

        return response()->json([
            'success' => true,

            'message' =>
                'Lấy hồ sơ nhà cung cấp thành công.',

            'data' => [
                'profile' =>
                    new ProviderProfileResource($profile),
            ],
        ]);
    }

    // Cập nhật hồ sơ Provider
    public function update(
        UpdateProviderProfileRequest $request
    ): JsonResponse {
        $user = $request->user();

        $profile = $user->providerProfile;

        if ($profile === null) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Hồ sơ nhà cung cấp chưa tồn tại.',
            ], 404);
        }

        $validated = $request->validated();

        $profile->update($validated);

        $profile->load('user');

        return response()->json([
            'success' => true,

            'message' =>
                'Cập nhật hồ sơ nhà cung cấp thành công.',

            'data' => [
                'profile' =>
                    new ProviderProfileResource($profile),
            ],
        ]);
    }

    /**
     * Public API: Lấy thông tin Provider để Customer xem. Chỉ hiển thị khi:
     * - account ACTIVE
     * - có providerProfile
     * - verification_status = APPROVED
     */
    public function show(
        User $provider
    ): JsonResponse {
        $provider->loadMissing(
            'providerProfile'
        );

        $profile = $provider->providerProfile;

        if (
            $provider->status !== 'ACTIVE' ||
            $profile === null ||
            $profile->verification_status !== 'APPROVED'
        ) {
            abort(404);
        }

        $profile->loadMissing('user');

        return response()->json([
            'success' => true,

            'message' =>
                'Lấy thông tin nhà cung cấp thành công.',

            'data' => [
                'provider' => [
                    'id' =>
                        $provider->id,

                    'name' =>
                        $provider->name,

                    'avatar' =>
                        $provider->avatar,

                    'profile' =>
                        new ProviderProfileResource(
                            $profile
                        ),
                ],
            ],
        ]);
    }
}