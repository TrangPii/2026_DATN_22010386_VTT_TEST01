<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProviderProfileResource;
use App\Models\ProviderProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminProviderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => [
                'nullable',
                'in:PENDING,APPROVED,REJECTED',
            ],

            'per_page' => [
                'nullable',
                'integer',
                'min:1',
                'max:100',
            ],
        ]);

        $query = ProviderProfile::query()
            ->with('user')
            ->latest();

        if (! empty($validated['status'])) {
            $query->where(
                'verification_status',
                $validated['status']
            );
        }

        $profiles = $query->paginate(
            $validated['per_page'] ?? 20
        );

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy danh sách nhà cung cấp thành công.',

            'data' => [
                'providers' =>
                    ProviderProfileResource::collection(
                        $profiles->items()
                    ),

                'pagination' => [
                    'current_page' =>
                        $profiles->currentPage(),

                    'last_page' =>
                        $profiles->lastPage(),

                    'total' =>
                        $profiles->total(),
                ],
            ],
        ]);
    }

    public function approve(
        ProviderProfile $profile
    ): JsonResponse {
        $profile->update([
            'verification_status' => 'APPROVED',
            'verified_at' => now(),
        ]);

        $profile->load('user');

        return response()->json([
            'success' => true,
            'message' =>
                'Đã phê duyệt nhà cung cấp.',

            'data' => [
                'profile' =>
                    new ProviderProfileResource($profile),
            ],
        ]);
    }

    public function reject(
        ProviderProfile $profile
    ): JsonResponse {
        DB::transaction(function () use ($profile): void {
        $profile->update([
            'verification_status' => 'REJECTED',
            'verified_at' => null,
        ]);

        /*
         * Tắt service của provider bị từ chối.
         */
        $profile
            ->user
            ->services()
            ->update([
                'status' => 'INACTIVE',
            ]);
        });

        $profile->load('user');

        return response()->json([
            'success' => true,
            'message' =>
                'Đã từ chối nhà cung cấp.',

            'data' => [
                'profile' =>
                    new ProviderProfileResource($profile),
            ],
        ]);
    }
}