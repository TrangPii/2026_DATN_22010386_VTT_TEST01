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
    public function index(
        Request $request
    ): JsonResponse {
        $validated =
            $request->validate([
                'verification_status' => [
                    'nullable',
                    'in:PENDING,APPROVED,REJECTED',
                ],

                'provider_status' => [
                    'nullable',
                    'in:ACTIVE,LOCKED',
                ],

                'per_page' => [
                    'nullable',
                    'integer',
                    'min:1',
                    'max:100',
                ],
            ]);

        $query =
            ProviderProfile::query()
                ->with('user')
                ->latest('created_at');

        if (
            ! empty(
                $validated[
                    'verification_status'
                ]
            )
        ) {
            $query->where(
                'verification_status',
                $validated[
                    'verification_status'
                ]
            );
        }

        if (
            ! empty(
                $validated[
                    'provider_status'
                ]
            )
        ) {
            $query->where(
                'provider_status',
                $validated[
                    'provider_status'
                ]
            );
        }

        $profiles =
            $query->paginate(
                $validated[
                    'per_page'
                ] ?? 20
            );

        return response()->json([
            'success' => true,

            'message' =>
                'Lấy danh sách nhà cung cấp thành công.',

            'data' => [
                'providers' =>
                    ProviderProfileResource::
                        collection(
                            $profiles->items()
                        ),

                'pagination' => [
                    'current_page' =>
                        $profiles
                            ->currentPage(),

                    'last_page' =>
                        $profiles
                            ->lastPage(),

                    'per_page' =>
                        $profiles
                            ->perPage(),

                    'total' =>
                        $profiles
                            ->total(),
                ],
            ],
        ]);
    }

    public function approve(
        ProviderProfile $profile
    ): JsonResponse {
        if (
            $profile
                ->verification_status !==
            ProviderProfile::
                VERIFICATION_PENDING
        ) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Chỉ hồ sơ đang chờ duyệt mới có thể được phê duyệt.',
            ], 422);
        }

        DB::transaction(
            function () use (
                $profile
            ): void {
                $profile->update([
                    'verification_status' =>
                        ProviderProfile::
                            VERIFICATION_APPROVED,

                    'provider_status' =>
                        ProviderProfile::
                            STATUS_ACTIVE,

                    'verified_at' =>
                        now(),
                ]);
            }
        );

        $profile->load('user');

        return response()->json([
            'success' => true,

            'message' =>
                'Đã phê duyệt nhà cung cấp.',

            'data' => [
                'profile' =>
                    new ProviderProfileResource(
                        $profile
                    ),
            ],
        ]);
    }

    public function reject(
        ProviderProfile $profile
    ): JsonResponse {
        if (
            $profile
                ->verification_status !==
            ProviderProfile::
                VERIFICATION_PENDING
        ) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Chỉ hồ sơ đang chờ duyệt mới có thể bị từ chối.',
            ], 422);
        }

        DB::transaction(
            function () use (
                $profile
            ): void {
                $profile->update([
                    'verification_status' =>
                        ProviderProfile::
                            VERIFICATION_REJECTED,

                    'provider_status' =>
                        null,

                    'verified_at' =>
                        null,
                ]);
            }
        );

        $profile->load('user');

        return response()->json([
            'success' => true,

            'message' =>
                'Đã từ chối hồ sơ nhà cung cấp.',

            'data' => [
                'profile' =>
                    new ProviderProfileResource(
                        $profile
                    ),
            ],
        ]);
    }

    public function updateStatus(
        Request $request,
        ProviderProfile $profile
    ): JsonResponse {
        $validated =
            $request->validate([
                'provider_status' => [
                    'required',
                    'in:ACTIVE,LOCKED',
                ],
            ]);

        if (
            $profile
                ->verification_status !==
            ProviderProfile::
                VERIFICATION_APPROVED
        ) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Chỉ Nhà cung cấp đã được phê duyệt mới có trạng thái hoạt động.',
            ], 422);
        }

        $profile->update([
            'provider_status' =>
                $validated[
                    'provider_status'
                ],
        ]);

        $profile->load('user');

        return response()->json([
            'success' => true,

            'message' =>
                $validated[
                    'provider_status'
                ] ===
                ProviderProfile::
                    STATUS_LOCKED
                    ? 'Đã khóa quyền Nhà cung cấp.'
                    : 'Đã mở khóa quyền Nhà cung cấp.',

            'data' => [
                'profile' =>
                    new ProviderProfileResource(
                        $profile
                    ),
            ],
        ]);
    }
}