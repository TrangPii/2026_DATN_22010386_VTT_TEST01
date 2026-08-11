@extends('admin.layouts.app')

@section('title', 'Chi tiết người dùng')

@section('header')
    Quản lý người dùng
@endsection

@section('content')

<div class="admin-page-heading">

    <div>
        <h1 class="admin-page-title">
            Chi tiết người dùng
        </h1>

        <p class="admin-page-subtitle">
            Thông tin tài khoản {{ $user->user_code }}.
        </p>
    </div>

</div>

<div class="admin-section-card">

    <div class="admin-detail-header">

        <div>
            <h2 class="admin-section-title">
                Thông tin người dùng
            </h2>
        </div>

    </div>

    <div class="user-detail-grid">

        <div class="user-detail-row">
            <div class="user-detail-label">
                Mã người dùng
            </div>

            <div class="user-detail-value">
                {{ $user->user_code }}
            </div>
        </div>

        <div class="user-detail-row">
            <div class="user-detail-label">
                Họ và tên
            </div>

            <div class="user-detail-value">
                {{ $user->name }}
            </div>
        </div>

        <div class="user-detail-row">
            <div class="user-detail-label">
                Số điện thoại
            </div>

            <div class="user-detail-value">
                {{ $user->phone ?? 'Chưa cập nhật' }}
            </div>
        </div>

        <div class="user-detail-row">
            <div class="user-detail-label">
                Email
            </div>

            <div class="user-detail-value">
                {{ $user->email }}
            </div>
        </div>

        <div class="user-detail-row">
            <div class="user-detail-label">
                Vai trò
            </div>

            <div class="user-detail-value">

                @if ($user->role === 'ADMIN')

                    <span class="status-badge status-badge-info">
                        Admin
                    </span>

                @else

                    <span class="status-badge status-badge-neutral">
                        Khách hàng
                    </span>

                @endif

            </div>
        </div>

        <div class="user-detail-row">
            <div class="user-detail-label">
                Trạng thái
            </div>

            <div class="user-detail-value">

                @if ($user->status === 'ACTIVE')

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

        <div class="user-detail-row">
            <div class="user-detail-label">
                Ngày đăng ký
            </div>

            <div class="user-detail-value">
                {{ $user->created_at
                    ? $user->created_at->format('d/m/Y H:i:s')
                    : '—'
                }}
            </div>
        </div>

        <div class="user-detail-row">
            <div class="user-detail-label">
                Đăng nhập cuối
            </div>

            <div class="user-detail-value">
                {{ $user->last_login_at
                    ? $user->last_login_at->format('d/m/Y H:i:s')
                    : 'Chưa đăng nhập'
                }}
            </div>
        </div>

    </div>

    <div class="admin-detail-footer">

        <a
            href="{{ route('admin.users.index') }}"
            class="btn btn-secondary"
        >
            ← Quay lại
        </a>

    </div>

</div>

@endsection