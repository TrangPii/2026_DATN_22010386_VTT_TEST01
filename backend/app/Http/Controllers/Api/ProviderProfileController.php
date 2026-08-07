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
    public function me(Request $request): JsonResponse
    {
        if ($request->user()->role !== 'PROVIDER') {
            abort(
                403,
                'Bạn không có quyền truy cập.'
            );
        }

        $profile = $request
            ->user()
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

    public function update(
        UpdateProviderProfileRequest $request
    ): JsonResponse {
        $provider = $request->user();

        $profile = $provider->providerProfile;

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

    public function show(
        User $provider
    ): JsonResponse {
        if (
            $provider->role !== 'PROVIDER' ||
            $provider->status !== 'ACTIVE'
        ) {
            abort(404);
        }

        $profile = $provider
            ->providerProfile()
            ->with('user')
            ->first();

        if (
            $profile === null ||
            $profile->verification_status !== 'APPROVED'
        ) {
            abort(404);
        }

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy thông tin nhà cung cấp thành công.',

            'data' => [
                'provider' => [
                    'id' => $provider->id,

                    'name' => $provider->name,

                    'avatar' => $provider->avatar,

                    'profile' =>
                        new ProviderProfileResource($profile),
                ],
            ],
        ]);
    }
}