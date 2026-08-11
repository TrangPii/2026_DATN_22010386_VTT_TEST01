@extends('admin.layouts.app')

@section('title', 'Chi tiết dịch vụ')

@section('header')
    Quản lý dịch vụ

    <p class="admin-page-subtitle">
        Xem thông tin chi tiết của dịch vụ.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">

    <div>
        <h1 class="admin-page-title">
            Chi tiết dịch vụ
        </h1>
    </div>

    <a
        href="{{ route('admin.services.index') }}"
        class="btn btn-secondary"
    >
        ← Quay lại
    </a>

</div>


<div class="admin-section-card">

    <div class="admin-detail-header">

        <h4 class="admin-section-title">
            Thông tin dịch vụ
        </h4>

    </div>


    <div class="detail-grid detail-grid-padding">

        <div class="detail-item">

            <div class="detail-label">
                ID dịch vụ
            </div>

            <div class="detail-value">
                #{{ $service->id }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Tên dịch vụ
            </div>

            <div class="detail-value">
                {{ $service->name }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Danh mục
            </div>

            <div class="detail-value">
                {{ $service->category?->name ?? '—' }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Trạng thái danh mục
            </div>

            <div class="detail-value">

                @if ($service->category?->status === 'ACTIVE')

                    <span class="status-badge status-badge-success">
                        Hoạt động
                    </span>

                @else

                    <span class="status-badge status-badge-danger">
                        Vô hiệu
                    </span>

                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Giá
            </div>

            <div class="detail-value">
                {{ number_format(
                    (float) $service->price,
                    0,
                    ',',
                    '.'
                ) }}
                đ
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Đơn vị giá
            </div>

            <div class="detail-value">
                {{ $service->price_unit ?: '—' }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Thời lượng dự kiến
            </div>

            <div class="detail-value">

                @if ($service->estimated_duration_minutes)

                    {{ $service->estimated_duration_minutes }}
                    phút

                @else

                    Chưa cập nhật

                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Trạng thái dịch vụ
            </div>

            <div class="detail-value">

                @if ($service->status === 'ACTIVE')

                    <span class="status-badge status-badge-success">
                        Hoạt động
                    </span>

                @else

                    <span class="status-badge status-badge-danger">
                        Vô hiệu
                    </span>

                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Số booking
            </div>

            <div class="detail-value">
                {{ $service->bookings_count }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Ngày tạo
            </div>

            <div class="detail-value">

                @if ($service->created_at)

                    {{ $service->created_at->format(
                        'd/m/Y H:i:s'
                    ) }}

                @else
                    —
                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Cập nhật cuối
            </div>

            <div class="detail-value">

                @if ($service->updated_at)

                    {{ $service->updated_at->format(
                        'd/m/Y H:i:s'
                    ) }}

                @else
                    —
                @endif

            </div>

        </div>

    </div>


    <div class="detail-description">

        <div class="detail-label">
            Mô tả
        </div>

        <div class="detail-value">
            {{ $service->description ?: 'Chưa có mô tả' }}
        </div>

    </div>

</div>


<div class="admin-section-card">

    <div class="admin-detail-header">

        <h4 class="admin-section-title">
            Nhà cung cấp
        </h4>

    </div>


    <div class="detail-grid detail-grid-padding">

        <div class="detail-item">

            <div class="detail-label">
                Tên Nhà cung cấp
            </div>

            <div class="detail-value">

                @if ($service->provider?->providerProfile)

                    <a
                        href="{{ route(
                            'admin.providers.show',
                            $service->provider->providerProfile
                        ) }}"
                        class="table-link"
                    >
                        {{
                            $service
                                ->provider
                                ->providerProfile
                                ->business_name
                        }}
                    </a>

                @else
                    —
                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Mã người dùng
            </div>

            <div class="detail-value">

                @if ($service->provider)

                    <a
                        href="{{ route(
                            'admin.users.show',
                            $service->provider
                        ) }}"
                        class="table-link"
                    >
                        {{ $service->provider->user_code }}
                    </a>

                @else
                    —
                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Chủ tài khoản
            </div>

            <div class="detail-value">
                {{ $service->provider?->name ?? '—' }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Email
            </div>

            <div class="detail-value">
                {{ $service->provider?->email ?? '—' }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Xác minh Nhà cung cấp
            </div>

            <div class="detail-value">

                @switch(
                    $service
                        ->provider
                        ?->providerProfile
                        ?->verification_status
                )

                    @case('APPROVED')

                        <span class="status-badge status-badge-success">
                            Đã duyệt
                        </span>

                        @break


                    @case('PENDING')

                        <span class="status-badge status-badge-warning">
                            Chờ duyệt
                        </span>

                        @break


                    @case('REJECTED')

                        <span class="status-badge status-badge-danger">
                            Bị từ chối
                        </span>

                        @break


                    @default

                        <span class="status-badge status-badge-neutral">
                            Chưa đăng ký
                        </span>

                @endswitch

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Trạng thái Nhà cung cấp
            </div>

            <div class="detail-value">

                @if (
                    $service
                        ->provider
                        ?->providerProfile
                        ?->verification_status !== 'APPROVED'
                )

                    <span class="status-badge status-badge-neutral">
                        —
                    </span>

                @elseif (
                    $service
                        ->provider
                        ?->providerProfile
                        ?->provider_status === 'ACTIVE'
                )

                    <span class="status-badge status-badge-success">
                        Hoạt động
                    </span>

                @else

                    <span class="status-badge status-badge-danger">
                        Vô hiệu
                    </span>

                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Trạng thái tài khoản
            </div>

            <div class="detail-value">

                @if ($service->provider?->status === 'ACTIVE')

                    <span class="status-badge status-badge-success">
                        Hoạt động
                    </span>

                @else

                    <span class="status-badge status-badge-danger">
                        Vô hiệu
                    </span>

                @endif

            </div>

        </div>

    </div>

</div>

@endsection