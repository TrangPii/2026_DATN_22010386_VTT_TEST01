@extends('admin.layouts.app')

@section('title', 'Chi tiết dịch vụ')

@section('content')
    <div
        class="actions"
        style="justify-content: space-between; margin-bottom: 24px;"
    >
        <h1
            class="page-title"
            style="margin-bottom: 0;"
        >
            Chi tiết dịch vụ
        </h1>

        <a
            href="{{ route('admin.services.index') }}"
            class="btn btn-secondary"
        >
            Quay lại
        </a>
    </div>

    @if (session('success'))
        <div class="alert alert-success">
            {{ session('success') }}
        </div>
    @endif

    @if (session('error'))
        <div class="alert alert-error">
            {{ session('error') }}
        </div>
    @endif

    <div class="card">
        <div class="card-header">
            Thông tin dịch vụ
        </div>

        <div style="padding: 20px;">
            <div class="detail-grid">
                <div class="detail-item">
                    <div class="detail-label">
                        ID
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
                        {{ $service->category?->name ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Trạng thái danh mục
                    </div>

                    <div class="detail-value">
                        {{ $service->category?->status ?? 'N/A' }}
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
                        {{ $service->price_unit }}
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
                        Trạng thái
                    </div>

                    <div class="detail-value">
                        <span class="badge">
                            {{ $service->status }}
                        </span>
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
                        {{ $service->created_at?->format(
                            'd/m/Y H:i'
                        ) }}
                    </div>
                </div>
            </div>

            <div
                class="detail-item"
                style="margin-top: 16px;"
            >
                <div class="detail-label">
                    Mô tả
                </div>

                <div>
                    {{ $service->description
                        ?: 'Chưa có mô tả' }}
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            Nhà cung cấp
        </div>

        <div style="padding: 20px;">
            <div class="detail-grid">
                <div class="detail-item">
                    <div class="detail-label">
                        Tên Nhà cung cấp
                    </div>

                    <div class="detail-value">
                        {{ $service->provider
                            ?->providerProfile
                            ?->business_name
                            ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Chủ tài khoản
                    </div>

                    <div class="detail-value">
                        {{ $service->provider?->name ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Email
                    </div>

                    <div class="detail-value">
                        {{ $service->provider?->email ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Xác minh Provider
                    </div>

                    <div class="detail-value">
                        {{ $service->provider
                            ?->providerProfile
                            ?->verification_status
                            ?? 'Chưa đăng ký' }}
                    </div>
                </div>
            </div>

            @if ($service->provider?->providerProfile)
                <div
                    class="actions"
                    style="margin-top: 20px;"
                >
                    <a
                        href="{{ route(
                            'admin.providers.show',
                            $service->provider->providerProfile
                        ) }}"
                        class="btn btn-secondary"
                    >
                        Xem Nhà cung cấp
                    </a>
                </div>
            @endif
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            Quản lý trạng thái
        </div>

        <div style="padding: 20px;">
            <form
                method="POST"
                action="{{ route(
                    'admin.services.status',
                    $service
                ) }}"
            >
                @csrf
                @method('PATCH')

                <input
                    type="hidden"
                    name="status"
                    value="{{ $service->status === 'ACTIVE'
                        ? 'INACTIVE'
                        : 'ACTIVE' }}"
                >

                @if ($service->status === 'ACTIVE')
                    <button
                        type="submit"
                        class="btn btn-warning"
                        onclick="return confirm(
                            'Tạm ngừng dịch vụ này?'
                        );"
                    >
                        Tạm ngừng dịch vụ
                    </button>
                @else
                    <button
                        type="submit"
                        class="btn btn-primary"
                    >
                        Kích hoạt dịch vụ
                    </button>
                @endif
            </form>
        </div>
    </div>
@endsection