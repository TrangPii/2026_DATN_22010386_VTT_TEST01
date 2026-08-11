@extends('admin.layouts.app')

@section('title', 'Chi tiết nhà cung cấp')

@section('header')
    Quản lý nhà cung cấp

    <p class="admin-page-subtitle">
        Xem thông tin hồ sơ và thực hiện xét duyệt Nhà cung cấp.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">

    <div>
        <h1 class="admin-page-title">
            Chi tiết nhà cung cấp
        </h1>
    </div>

    <a
        href="{{ route('admin.providers.index') }}"
        class="btn btn-secondary"
    >
        ← Quay lại
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


<div class="admin-section-card">

    <div class="admin-detail-header">
        <h4 class="admin-section-title">
            Thông tin nhà cung cấp
        </h4>
    </div>

    <div class="detail-grid detail-grid-padding">

        <div class="detail-item">
            <div class="detail-label">
                Tên nhà cung cấp
            </div>

            <div class="detail-value">
                {{ $provider->business_name }}
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Trạng thái xác minh
            </div>

            <div class="detail-value">

                @switch($provider->verification_status)

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

                @endswitch

            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Trạng thái hoạt động
            </div>

            <div class="detail-value">

                @if ($provider->verification_status !== 'APPROVED')

                    <span class="status-badge status-badge-neutral">
                        Chưa áp dụng
                    </span>

                @elseif ($provider->provider_status === 'ACTIVE')

                    <span class="status-badge status-badge-success">
                        Hoạt động
                    </span>

                @else

                    <span class="status-badge status-badge-danger">
                        Đã khóa
                    </span>

                @endif

            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Địa chỉ
            </div>

            <div class="detail-value">
                {{ $provider->address ?: 'Chưa cập nhật' }}
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Kinh nghiệm
            </div>

            <div class="detail-value">
                {{ $provider->experience_years }} năm
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Giấy tờ định danh
            </div>

            <div class="detail-value">
                {{ $provider->identity_number ?: 'Chưa cập nhật' }}
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Ngày đăng ký NCC
            </div>

            <div class="detail-value">
                @if ($provider->created_at)
                    {{ $provider->created_at->format('d/m/Y H:i:s') }}
                @else
                    —
                @endif
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Thao tác cuối
            </div>

            <div class="detail-value">
                @if ($provider->updated_at)
                    {{ $provider->updated_at->format('d/m/Y H:i:s') }}
                @else
                    —
                @endif
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Ngày xác minh
            </div>

            <div class="detail-value">
                {{ $provider->verified_at
                    ? $provider->verified_at->format('d/m/Y H:i:s')
                    : 'Chưa xác minh'
                }}
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Đánh giá
            </div>

            <div class="detail-value">
                {{ number_format(
                    (float) $provider->average_rating,
                    1
                ) }}
                / 5
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Tổng lượt đánh giá
            </div>

            <div class="detail-value">
                {{ $provider->total_reviews }}
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Số dịch vụ
            </div>

            <div class="detail-value">
                {{ $provider->user?->services_count ?? 0 }}
            </div>
        </div>

    </div>

    <div class="detail-description">
        <div class="detail-label">
            Giới thiệu
        </div>

        <div class="detail-value">
            {{ $provider->description ?: 'Chưa cập nhật' }}
        </div>
    </div>

</div>


<div class="admin-section-card">

    <div class="admin-detail-header">
        <h4 class="admin-section-title">
            Thông tin tài khoản
        </h4>
    </div>

    <div class="detail-grid detail-grid-padding">

        <div class="detail-item">
            <div class="detail-label">
                Mã người dùng
            </div>

            <div class="detail-value">

                @if ($provider->user)

                    <a
                        href="{{ route(
                            'admin.users.show',
                            $provider->user
                        ) }}"
                        class="table-link"
                    >
                        {{ $provider->user->user_code }}
                    </a>

                @else
                    —
                @endif

            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Họ và tên
            </div>

            <div class="detail-value">
                {{ $provider->user?->name ?? '—' }}
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Email
            </div>

            <div class="detail-value">
                {{ $provider->user?->email ?? '—' }}
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Số điện thoại
            </div>

            <div class="detail-value">
                {{ $provider->user?->phone ?: 'Chưa cập nhật' }}
            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Trạng thái tài khoản
            </div>

            <div class="detail-value">

                @if ($provider->user?->status === 'ACTIVE')

                    <span class="status-badge status-badge-success">
                        Hoạt động
                    </span>

                @else

                    <span class="status-badge status-badge-danger">
                        Đã khóa
                    </span>

                @endif

            </div>
        </div>

        <div class="detail-item">
            <div class="detail-label">
                Số đơn Provider
            </div>

            <div class="detail-value">
                {{ $provider->user?->provider_bookings_count ?? 0 }}
            </div>
        </div>

    </div>

</div>


@if ($provider->verification_status === 'PENDING')

    <div class="admin-section-card">

        <div class="admin-detail-header">
            <h4 class="admin-section-title">
                Xét duyệt hồ sơ
            </h4>
        </div>

        <div class="admin-detail-actions">

            <form
                method="POST"
                action="{{ route(
                    'admin.providers.approve',
                    $provider
                ) }}"
                onsubmit="return confirm(
                    'Bạn có chắc muốn phê duyệt hồ sơ này?'
                );"
            >
                @csrf

                <button
                    type="submit"
                    class="btn btn-primary"
                >
                    Phê duyệt
                </button>

            </form>

            <form
                method="POST"
                action="{{ route(
                    'admin.providers.reject',
                    $provider
                ) }}"
                onsubmit="return confirm(
                    'Bạn có chắc muốn từ chối hồ sơ này?'
                );"
            >
                @csrf

                <button
                    type="submit"
                    class="btn btn-danger"
                >
                    Từ chối
                </button>

            </form>

        </div>

    </div>

@endif

@endsection