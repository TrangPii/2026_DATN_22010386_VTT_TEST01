<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ProviderProfile;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class ServiceController extends Controller
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

                'status' => [
                    'nullable',
                    'in:ACTIVE,INACTIVE',
                ],

                'category_id' => [
                    'nullable',
                    'integer',
                    'exists:service_categories,id',
                ],

                'provider_id' => [
                    'nullable',
                    'integer',
                    'exists:users,id',
                ],
            ]);

        $query =
            Service::query()
                ->with([
                    'category',
                    'provider.providerProfile',
                ])
                ->latest();

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
                            'name',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhere(
                            'description',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhereHas(
                            'provider',
                            function (
                                $providerQuery
                            ) use (
                                $search
                            ): void {
                                $providerQuery
                                    ->where(
                                        'name',
                                        'like',
                                        "%{$search}%"
                                    )
                                    ->orWhere(
                                        'email',
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
                $validated['status']
            )
        ) {
            $query->where(
                'status',
                $validated['status']
            );
        }

        if (
            ! empty(
                $validated[
                    'category_id'
                ]
            )
        ) {
            $query->where(
                'category_id',
                $validated[
                    'category_id'
                ]
            );
        }

        if (
            ! empty(
                $validated[
                    'provider_id'
                ]
            )
        ) {
            $query->where(
                'provider_id',
                $validated[
                    'provider_id'
                ]
            );
        }

        $services =
            $query
                ->paginate(10)
                ->withQueryString();

        /*
         * Phase 2 mới đổi Category
         * sang created_at DESC.
         */
        $categories =
            ServiceCategory::query()
                ->orderBy(
                    'display_order'
                )
                ->orderBy(
                    'name'
                )
                ->get();

        /*
         * Chỉ Provider thực sự đang hoạt động
         * mới xuất hiện trong filter Provider.
         */
        $providers =
            User::query()
                ->where(
                    'status',
                    'ACTIVE'
                )
                ->whereHas(
                    'providerProfile',
                    function (
                        $query
                    ): void {
                        $query
                            ->where(
                                'verification_status',
                                ProviderProfile::
                                    VERIFICATION_APPROVED
                            )
                            ->where(
                                'provider_status',
                                ProviderProfile::
                                    STATUS_ACTIVE
                            );
                    }
                )
                ->orderBy(
                    'name'
                )
                ->get();

        return view(
            'admin.services.service_list',
            compact(
                'services',
                'categories',
                'providers'
            )
        );
    }

    public function show(
        Service $service
    ): View {
        $service->load([
            'category',
            'provider.providerProfile',
        ]);

        $service->loadCount([
            'bookings',
        ]);

        return view(
            'admin.services.service_detail',
            compact('service')
        );
    }

    public function updateStatus(
        Request $request,
        Service $service
    ): RedirectResponse {
        $validated =
            $request->validate([
                'status' => [
                    'required',
                    'in:ACTIVE,INACTIVE',
                ],
            ]);

        if (
            $validated['status'] ===
            'ACTIVE'
        ) {
            $service->load([
                'category',
                'provider.providerProfile',
            ]);

            if (
                $service->category ===
                    null
                || $service
                    ->category
                    ->status !==
                    'ACTIVE'
            ) {
                return back()->with(
                    'error',
                    'Không thể kích hoạt vì danh mục hiện không hoạt động.'
                );
            }

            $profile =
                $service
                    ->provider
                    ?->providerProfile;

            if (
                $service->provider ===
                    null
                || $service
                    ->provider
                    ->status !==
                    'ACTIVE'
                || $profile === null
                || $profile
                    ->verification_status !==
                    ProviderProfile::
                        VERIFICATION_APPROVED
                || $profile
                    ->provider_status !==
                    ProviderProfile::
                        STATUS_ACTIVE
            ) {
                return back()->with(
                    'error',
                    'Không thể kích hoạt vì Nhà cung cấp hiện không đủ điều kiện.'
                );
            }
        }

        $service->update([
            'status' =>
                $validated['status'],
        ]);

        return back()->with(
            'success',
            $validated['status'] ===
                'ACTIVE'
                ? 'Đã kích hoạt dịch vụ.'
                : 'Đã tạm ngừng dịch vụ.'
        );
    }
}