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
    public function index(
        Request $request
    ): View {
        $validated =
            $request->validate([
                'search' => [
                    'nullable',
                    'string',
                    'max:100',
                ],

                'verification_status' => [
                    'nullable',
                    'in:PENDING,APPROVED,REJECTED',
                ],

                'provider_status' => [
                    'nullable',
                    'in:ACTIVE,LOCKED',
                ],
            ]);

        /*
         * Lấy TOÀN BỘ hồ sơ Provider:
         *
         * PENDING
         * APPROVED
         * REJECTED
         *
         * Mặc định mới nhất trước.
         */
        $query =
            ProviderProfile::query()
                ->with('user')
                ->latest('created_at');

        if (
            ! empty(
                $validated['search']
            )
        ) {
            $search =
                trim(
                    $validated['search']
                );

            $query->where(
                function (
                    $query
                ) use ($search): void {
                    $query
                        ->where(
                            'business_name',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhereHas(
                            'user',
                            function (
                                $userQuery
                            ) use (
                                $search
                            ): void {
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
                                    )
                                    ->orWhere(
                                        'id',
                                        'like',
                                        "%{$search}%"
                                    );
                            }
                        );
                }
            );
        }

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

        $providers =
            $query
                ->paginate(10)
                ->withQueryString();

        return view(
            'admin.providers.provider_list',
            compact('providers')
        );
    }

    public function show(
        ProviderProfile $provider
    ): View {
        $provider->load('user');

        $provider
            ->user
            ?->loadCount([
                'services',
                'providerBookings',
            ]);

        return view(
            'admin.providers.provider_detail',
            compact('provider')
        );
    }

    /*
     * Chỉ hồ sơ PENDING mới được APPROVE.
     */
    public function approve(
        ProviderProfile $provider
    ): RedirectResponse {
        if (
            $provider
                ->verification_status !==
            ProviderProfile::
                VERIFICATION_PENDING
        ) {
            return back()->with(
                'error',
                'Chỉ hồ sơ đang chờ duyệt mới có thể được phê duyệt.'
            );
        }

        DB::transaction(
            function () use (
                $provider
            ): void {
                $provider->update([
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

        return back()->with(
            'success',
            'Đã phê duyệt Nhà cung cấp.'
        );
    }

    /*
     * REJECT chỉ mang ý nghĩa: từ chối hồ sơ xét duyệt.
     * Không dùng REJECT để khóa Provider đã APPROVED.
     */
    public function reject(
        ProviderProfile $provider
    ): RedirectResponse {
        if (
            $provider
                ->verification_status !==
            ProviderProfile::
                VERIFICATION_PENDING
        ) {
            return back()->with(
                'error',
                'Chỉ hồ sơ đang chờ duyệt mới có thể bị từ chối.'
            );
        }

        DB::transaction(
            function () use (
                $provider
            ): void {
                $provider->update([
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

        return back()->with(
            'success',
            'Đã từ chối hồ sơ Nhà cung cấp.'
        );
    }

    /*
     * Khóa / mở khóa QUYỀN PROVIDER.
     * Không thay users.status.
     * User vẫn sử dụng Customer mode.
     */
    public function updateStatus(
        Request $request,
        ProviderProfile $provider
    ): RedirectResponse {
        $validated =
            $request->validate([
                'provider_status' => [
                    'required',
                    'in:ACTIVE,LOCKED',
                ],
            ]);

        if (
            $provider
                ->verification_status !==
            ProviderProfile::
                VERIFICATION_APPROVED
        ) {
            return back()->with(
                'error',
                'Chỉ Nhà cung cấp đã được phê duyệt mới có trạng thái hoạt động.'
            );
        }

        $provider->update([
            'provider_status' =>
                $validated[
                    'provider_status'
                ],
        ]);

        /*
         * Không đổi status của services.
         *
         * Public API sẽ tự ẩn services khi Provider bị LOCKED.
         *
         * Khi mở khóa NCC, các dịch vụ ACTIVE trước đó tự khả dụng lại.
         */
        return back()->with(
            'success',
            $validated[
                'provider_status'
            ] ===
            ProviderProfile::
                STATUS_LOCKED
                ? 'Đã khóa quyền Nhà cung cấp.'
                : 'Đã mở khóa quyền Nhà cung cấp.'
        );
    }
}