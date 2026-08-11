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
        $validated = $request->validate([
            'user_code' => [
                'nullable',
                'string',
                'max:20',
            ],

            'business_name' => [
                'nullable',
                'string',
                'max:150',
            ],

            'owner_name' => [
                'nullable',
                'string',
                'max:100',
            ],

            'email' => [
                'nullable',
                'string',
                'max:150',
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

        $query = ProviderProfile::query()
            ->with('user')
            ->orderByDesc('created_at')
            ->orderByDesc('id');

        if (
            ! empty(
                $validated['user_code']
            )
        ) {
            $userCode = trim(
                $validated['user_code']
            );

            $query->whereHas(
                'user',
                fn ($userQuery) =>
                    $userQuery->where(
                        'user_code',
                        'like',
                        "%{$userCode}%"
                    )
            );
        }

        if (
            ! empty(
                $validated['business_name']
            )
        ) {
            $businessName = trim(
                $validated['business_name']
            );

            $query->where(
                'business_name',
                'like',
                "%{$businessName}%"
            );
        }

        if (
            ! empty(
                $validated['owner_name']
            )
        ) {
            $ownerName = trim(
                $validated['owner_name']
            );

            $query->whereHas(
                'user',
                fn ($userQuery) =>
                    $userQuery->where(
                        'name',
                        'like',
                        "%{$ownerName}%"
                    )
            );
        }

        if (
            ! empty(
                $validated['email']
            )
        ) {
            $email = trim(
                $validated['email']
            );

            $query->whereHas(
                'user',
                fn ($userQuery) =>
                    $userQuery->where(
                        'email',
                        'like',
                        "%{$email}%"
                    )
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

        $providers = $query
            ->paginate(6)
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

    public function approve(
        ProviderProfile $provider
    ): RedirectResponse {
        if (
            $provider->verification_status !==
            ProviderProfile::VERIFICATION_PENDING
        ) {
            return back()->with(
                'error',
                'Chỉ hồ sơ đang chờ duyệt mới có thể được phê duyệt.'
            );
        }

        DB::transaction(
            function () use ($provider): void {
                $provider->update([
                    'verification_status' =>
                        ProviderProfile::VERIFICATION_APPROVED,

                    'provider_status' =>
                        ProviderProfile::STATUS_ACTIVE,

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

    public function reject(
        ProviderProfile $provider
    ): RedirectResponse {
        if (
            $provider->verification_status !==
            ProviderProfile::VERIFICATION_PENDING
        ) {
            return back()->with(
                'error',
                'Chỉ hồ sơ đang chờ duyệt mới có thể bị từ chối.'
            );
        }

        DB::transaction(
            function () use ($provider): void {
                $provider->update([
                    'verification_status' =>
                        ProviderProfile::VERIFICATION_REJECTED,

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

    public function updateStatus(
        Request $request,
        ProviderProfile $provider
    ): RedirectResponse {
        $validated = $request->validate([
            'provider_status' => [
                'required',
                'in:ACTIVE,LOCKED',
            ],
        ]);

        if (
            $provider->verification_status !==
            ProviderProfile::VERIFICATION_APPROVED
        ) {
            return back()->with(
                'error',
                'Chỉ Nhà cung cấp đã được phê duyệt mới có trạng thái hoạt động.'
            );
        }

        if (
            $provider->provider_status ===
            $validated['provider_status']
        ) {
            return back()->with(
                'error',
                'Nhà cung cấp đã ở trạng thái này.'
            );
        }

        $provider->update([
            'provider_status' =>
                $validated['provider_status'],
        ]);

        return back()->with(
            'success',
            $validated['provider_status'] ===
            ProviderProfile::STATUS_LOCKED
                ? 'Đã khóa quyền Nhà cung cấp.'
                : 'Đã mở khóa quyền Nhà cung cấp.'
        );
    }
}