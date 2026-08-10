@extends('admin.layouts.app')

@section('title', 'Chi tiết Nhà cung cấp')

@section('content')
    <div class="actions" style="justify-content: space-between; margin-bottom: 24px;">
        <h1 class="page-title" style="margin-bottom: 0;">
            Chi tiết Nhà cung cấp
        </h1>

        <a
            href="{{ route('admin.providers.index') }}"
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
            Thông tin hồ sơ Nhà cung cấp
        </div>

        <div style="padding: 20px;">
            <div class="detail-grid">
                <div class="detail-item">
                    <div class="detail-label">
                        Tên Nhà cung cấp
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
                                <span class="badge">
                                    Đã duyệt
                                </span>
                                @break

                            @case('PENDING')
                                <span class="badge">
                                    Chờ duyệt
                                </span>
                                @break

                            @case('REJECTED')
                                <span class="badge">
                                    Bị từ chối
                                </span>
                                @break
                        @endswitch
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
                        Ngày gửi hồ sơ
                    </div>

                    <div class="detail-value">
                        {{ $provider->created_at?->format('d/m/Y H:i') ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Ngày xác minh
                    </div>

                    <div class="detail-value">
                        {{ $provider->verified_at?->format('d/m/Y H:i') ?? 'Chưa xác minh' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Đánh giá trung bình
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
            </div>

            <div
                class="detail-item"
                style="margin-top: 16px;"
            >
                <div class="detail-label">
                    Giới thiệu
                </div>

                <div>
                    {{ $provider->description ?: 'Chưa cập nhật' }}
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            Thông tin tài khoản
        </div>

        <div style="padding: 20px;">
            <div class="detail-grid">
                <div class="detail-item">
                    <div class="detail-label">
                        User ID
                    </div>

                    <div class="detail-value">
                        #{{ $provider->user?->id ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Họ tên
                    </div>

                    <div class="detail-value">
                        {{ $provider->user?->name ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Email
                    </div>

                    <div class="detail-value">
                        {{ $provider->user?->email ?? 'N/A' }}
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
                        Role
                    </div>

                    <div class="detail-value">
                        {{ $provider->user?->role ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Trạng thái tài khoản
                    </div>

                    <div class="detail-value">
                        <span class="badge">
                            {{ $provider->user?->status ?? 'N/A' }}
                        </span>
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

                <div class="detail-item">
                    <div class="detail-label">
                        Số đơn Provider
                    </div>

                    <div class="detail-value">
                        {{ $provider->user?->provider_bookings_count ?? 0 }}
                    </div>
                </div>
            </div>

            @if ($provider->user)
                <div
                    class="actions"
                    style="margin-top: 20px;"
                >
                    <a
                        href="{{ route(
                            'admin.users.show',
                            $provider->user
                        ) }}"
                        class="btn btn-secondary"
                    >
                        Xem tài khoản
                    </a>
                </div>
            @endif
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            Xét duyệt hồ sơ
        </div>

        <div style="padding: 20px;">
            <p style="margin-top: 0;">
                Việc phê duyệt chỉ cấp thêm quyền Nhà cung cấp.
                Tài khoản vẫn giữ role CUSTOMER.
            </p>

            <div class="actions">
                @if ($provider->verification_status !== 'APPROVED')
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
                @endif

                @if ($provider->verification_status !== 'REJECTED')
                    <form
                        method="POST"
                        action="{{ route(
                            'admin.providers.reject',
                            $provider
                        ) }}"
                        onsubmit="return confirm(
                            'Bạn có chắc muốn từ chối hoặc thu hồi quyền Nhà cung cấp này?'
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
                @endif
            </div>
        </div>
    </div>
@endsection