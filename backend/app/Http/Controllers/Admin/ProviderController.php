<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ProviderProfile;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class ProviderController extends Controller
{
    // Danh sách hồ sơ đăng ký Nhà cung cấp
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'search' => [
                'nullable',
                'string',
                'max:100',
            ],

            'status' => [
                'nullable',
                'in:PENDING,APPROVED,REJECTED',
            ],
        ]);

        $query = ProviderProfile::query()
            ->with('user')
            ->latest();

        /*
         * Tìm theo:
         * - business_name
         * - tên user
         * - email
         * - số điện thoại
         */
        if (! empty($validated['search'])) {
            $search = trim(
                $validated['search']
            );

            $query->where(
                function ($query) use ($search): void {
                    $query
                        ->where(
                            'business_name',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhereHas(
                            'user',
                            function ($userQuery) use ($search): void {
                                $userQuery
                                    ->where(
                                        'name',
                                        'like',
                                        "%{$search}%"
                                    )
                                    ->orWhere(
                                        'email',
                                        'like',
                                        "%{$search}%"
                                    )
                                    ->orWhere(
                                        'phone',
                                        'like',
                                        "%{$search}%"
                                    );
                            }
                        );
                }
            );
        }

        if (! empty($validated['status'])) {
            $query->where(
                'verification_status',
                $validated['status']
            );
        }

        $providers = $query
            ->paginate(10)
            ->withQueryString();

        return view(
            'admin.providers.provider_list',
            compact('providers')
        );
    }

    // Xem chi tiết hồ sơ Nhà cung cấp
    public function show(
        ProviderProfile $provider
    ): View {
        $provider->load('user');

        $provider->user?->loadCount([
            'services',
            'providerBookings',
        ]);

        return view(
            'admin.providers.provider_detail',
            compact('provider')
        );
    }

    /**
     * Admin phê duyệt hồ sơ Nhà cung cấp.
     *
     * Không thay users.role.
     * User vẫn là CUSTOMER và được cấp thêm
     * Provider capability thông qua ProviderProfile.
     */
    public function approve(
        ProviderProfile $provider
    ): RedirectResponse {
        if (
            $provider->verification_status === 'APPROVED'
        ) {
            return back()->with(
                'error',
                'Hồ sơ này đã được phê duyệt trước đó.'
            );
        }

        DB::transaction(
            function () use ($provider): void {
                $provider->update([
                    'verification_status' =>
                        'APPROVED',

                    'verified_at' =>
                        now(),
                ]);
            }
        );

        return back()->with(
            'success',
            'Đã phê duyệt Nhà cung cấp.'
        );
    }

    // Admin từ chối hoặc thu hồi quyền Nhà cung cấp
    public function reject(
        ProviderProfile $provider
    ): RedirectResponse {
        if (
            $provider->verification_status === 'REJECTED'
        ) {
            return back()->with(
                'error',
                'Hồ sơ này đã ở trạng thái bị từ chối.'
            );
        }

        DB::transaction(
            function () use ($provider): void {
                $provider->update([
                    'verification_status' =>
                        'REJECTED',

                    'verified_at' =>
                        null,
                ]);

                // Khi Provider bị từ chối / thu hồi quyền, toàn bộ service phải ngừng hoạt động
                $provider
                    ->user
                    ?->services()
                    ->update([
                        'status' =>
                            'INACTIVE',
                    ]);
            }
        );

        return back()->with(
            'success',
            'Đã từ chối Nhà cung cấp.'
        );
    }
}