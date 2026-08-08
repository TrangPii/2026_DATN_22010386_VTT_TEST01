@extends('admin.layouts.app')

@section('title', 'Chi tiết người dùng')
@section('header', 'Chi tiết người dùng')

@section('content')

<div style="
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:16px;
    margin-bottom:24px;
">

    <div>
        <h1 style="margin:0;">
            {{ $user->name }}
        </h1>

        <div style="
            color:#6b7280;
            margin-top:6px;
        ">
            {{ $user->email }}
        </div>
    </div>

    <a
        href="{{ route('admin.users.index') }}"
        class="btn btn-secondary"
    >
        ← Quay lại
    </a>

</div>

@if(session('success'))
    <div class="alert alert-success">
        {{ session('success') }}
    </div>
@endif

@if(session('error'))
    <div class="alert alert-error">
        {{ session('error') }}
    </div>
@endif

<div class="detail-grid">

    <div class="detail-item">
        <div class="detail-label">
            ID
        </div>

        <div class="detail-value">
            {{ $user->id }}
        </div>
    </div>

    <div class="detail-item">
        <div class="detail-label">
            Vai trò
        </div>

        <div class="detail-value">
            {{ $user->role }}
        </div>
    </div>

    <div class="detail-item">
        <div class="detail-label">
            Trạng thái
        </div>

        <div class="detail-value">
            {{ $user->status }}
        </div>
    </div>

    <div class="detail-item">
        <div class="detail-label">
            Số điện thoại
        </div>

        <div class="detail-value">
            {{ $user->phone ?? 'Chưa cập nhật' }}
        </div>
    </div>

    <div class="detail-item">
        <div class="detail-label">
            Đăng nhập cuối
        </div>

        <div class="detail-value">
            {{ $user->last_login_at
                ? $user->last_login_at->format('d/m/Y H:i')
                : 'Chưa đăng nhập'
            }}
        </div>
    </div>

    <div class="detail-item">
        <div class="detail-label">
            Ngày tạo
        </div>

        <div class="detail-value">
            {{ $user->created_at?->format('d/m/Y H:i') }}
        </div>
    </div>

</div>

@if($user->role === 'CUSTOMER')

    <div class="card">

        <div class="card-header">
            Thống kê Customer
        </div>

        <div style="padding:20px;">

            Tổng booking:
            <strong>
                {{ $user->customerBookings->count() }}
            </strong>

        </div>

    </div>

@endif

@if($user->role === 'PROVIDER')

    <div class="card">

        <div class="card-header">
            Thông tin Provider
        </div>

        <div style="padding:20px;">

            @if($user->providerProfile)

                <div class="detail-grid">

                    <div class="detail-item">
                        <div class="detail-label">
                            Business name
                        </div>

                        <div class="detail-value">
                            {{ $user->providerProfile->business_name }}
                        </div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">
                            Xác minh
                        </div>

                        <div class="detail-value">
                            {{ $user->providerProfile->verification_status }}
                        </div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">
                            Rating
                        </div>

                        <div class="detail-value">
                            {{ number_format(
                                $user->providerProfile->average_rating,
                                1
                            ) }}
                        </div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">
                            Dịch vụ
                        </div>

                        <div class="detail-value">
                            {{ $user->services->count() }}
                        </div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">
                            Booking nhận
                        </div>

                        <div class="detail-value">
                            {{ $user->providerBookings->count() }}
                        </div>
                    </div>

                </div>

            @else

                Provider chưa có hồ sơ.

            @endif

        </div>

    </div>

@endif

@if($user->role !== 'ADMIN')

    <div class="card">

        <div class="card-header">
            Quản lý tài khoản
        </div>

        <div style="padding:20px;">

            <form
                method="POST"
                action="{{ route(
                    'admin.users.status',
                    $user
                ) }}"
            >
                @csrf
                @method('PATCH')

                <input
                    type="hidden"
                    name="status"
                    value="{{ $user->status === 'ACTIVE'
                        ? 'LOCKED'
                        : 'ACTIVE'
                    }}"
                >

                <button
                    type="submit"
                    class="btn {{ $user->status === 'ACTIVE'
                        ? 'btn-warning'
                        : 'btn-primary'
                    }}"
                >
                    {{ $user->status === 'ACTIVE'
                        ? 'Khóa tài khoản'
                        : 'Mở khóa tài khoản'
                    }}
                </button>

            </form>

        </div>

    </div>

@endif

@endsection