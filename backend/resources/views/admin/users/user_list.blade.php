@extends('admin.layouts.app')

@section('title', 'Quản lý người dùng')

@section('header')
    Quản lý người dùng
    <p class="admin-page-subtitle">
        Quản lý tài khoản và trạng thái hoạt động của người dùng.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">
    <div>
        <h1 class="admin-page-title">
            Danh sách người dùng
        </h1>
    </div>
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

@if ($errors->any())
    <div class="alert alert-error">
        {{ $errors->first() }}
    </div>
@endif

<div class="admin-section-card">

    <form
        method="GET"
        action="{{ route('admin.users.index') }}"
        class="admin-filter-form"
    >
        <div class="admin-filter-grid admin-filter-grid-users">

            <div class="admin-filter-field">
                <label for="user_code">
                    Mã người dùng
                </label>

                <input
                    id="user_code"
                    type="text"
                    name="user_code"
                    class="form-control"
                    value="{{ request('user_code') }}"
                    placeholder="Nhập mã người dùng"
                    maxlength="20"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="name">
                    Họ và tên
                </label>

                <input
                    id="name"
                    type="text"
                    name="name"
                    class="form-control"
                    value="{{ request('name') }}"
                    placeholder="Nhập họ và tên"
                    maxlength="100"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="phone">
                    Số điện thoại
                </label>

                <input
                    id="phone"
                    type="text"
                    name="phone"
                    class="form-control"
                    value="{{ request('phone') }}"
                    placeholder="Nhập số điện thoại"
                    maxlength="30"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="email">
                    Email
                </label>

                <input
                    id="email"
                    type="text"
                    name="email"
                    class="form-control"
                    value="{{ request('email') }}"
                    placeholder="Nhập email"
                    maxlength="150"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="role">
                    Vai trò
                </label>

                <select
                    id="role"
                    name="role"
                    class="form-control"
                >
                    <option value="">
                        Tất cả
                    </option>

                    <option
                        value="CUSTOMER"
                        @selected(request('role') === 'CUSTOMER')
                    >
                        Khách hàng
                    </option>

                    <option
                        value="ADMIN"
                        @selected(request('role') === 'ADMIN')
                    >
                        Admin
                    </option>
                </select>
            </div>

            <div class="admin-filter-field">
                <label for="status">
                    Trạng thái
                </label>

                <select
                    id="status"
                    name="status"
                    class="form-control"
                >
                    <option value="">
                        Tất cả
                    </option>

                    <option
                        value="ACTIVE"
                        @selected(request('status') === 'ACTIVE')
                    >
                        Hoạt động
                    </option>

                    <option
                        value="LOCKED"
                        @selected(request('status') === 'LOCKED')
                    >
                        Đã khóa
                    </option>
                </select>
            </div>

        </div>

        <div class="admin-filter-actions">
            <button
                type="submit"
                class="btn btn-primary"
            >
                Tìm kiếm
            </button>

            <a
                href="{{ route('admin.users.index') }}"
                class="btn btn-secondary"
            >
                Thiết lập lại
            </a>
        </div>
    </form>

</div>

<div class="admin-section-card">

    <div class="admin-table-header">
        <div class="admin-table-header2">
            <h4 class="admin-section-title">
                Bảng tìm kiếm
            </h4>

            <span class="admin-result-count">
                {{ $users->total() }} bản ghi
            </span>
        </div>
    </div>

    <div class="admin-table-scroll">

        <table class="admin-data-table admin-user-table">

            <thead>
                <tr>
                    <th>STT</th>
                    <th>Mã người dùng</th>
                    <th>Họ và tên</th>
                    <th>Số điện thoại</th>
                    <th>Email</th>
                    <th>Vai trò</th>
                    <th>Ngày đăng ký</th>
                    <th>Đăng nhập cuối</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>

            <tbody>

                @forelse ($users as $user)

                    <tr>

                        <td class="table-index">
                            {{ $users->firstItem() + $loop->index }}
                        </td>

                        <td class="table-code">
                            {{ $user->user_code }}
                        </td>

                        <td>
                            <strong>
                                {{ $user->name }}
                            </strong>
                        </td>

                        <td class="table-phone">
                            {{ $user->phone ?? '—' }}
                        </td>

                        <td class="table-email">
                            {{ $user->email }}
                        </td>

                        <td>
                            @if ($user->role === 'ADMIN')
                                <span class="status-badge status-badge-info">
                                    Admin
                                </span>
                            @else
                                <span class="status-badge status-badge-neutral">
                                    Khách hàng
                                </span>
                            @endif
                        </td>

                        <td class="table-date">
                            @if ($user->created_at)
                                <span class="date-value">
                                    {{ $user->created_at->format('d/m/Y') }}
                                </span>

                                <span class="time-value">
                                    {{ $user->created_at->format('H:i:s') }}
                                </span>
                            @else
                                —
                            @endif
                        </td>

                        <td class="table-date">
                            @if ($user->last_login_at)
                                <span class="date-value">
                                    {{ $user->last_login_at->format('d/m/Y') }}
                                </span>

                                <span class="time-value">
                                    {{ $user->last_login_at->format('H:i:s') }}
                                </span>
                            @else
                                <span class="table-muted">
                                    Chưa đăng nhập
                                </span>
                            @endif
                        </td>

                        <td class="table-status">
                            @if ($user->status === 'ACTIVE')
                                <span class="status-badge status-badge-success">
                                    Hoạt động
                                </span>
                            @else
                                <span class="status-badge status-badge-danger">
                                    Đã khóa
                                </span>
                            @endif
                        </td>

                        <td class="table-actions">
                            <div class="table-actions">

                                <a
                                    href="{{ route('admin.users.show', $user) }}"
                                    class="icon-action-button"
                                    title="Xem chi tiết"
                                    aria-label="Xem chi tiết người dùng {{ $user->user_code }}"
                                >
                                    <span aria-hidden="true">
                                        i
                                    </span>
                                </a>

                                @if ($user->role !== 'ADMIN')

                                    @if ($user->status === 'ACTIVE')

                                        <form
                                            method="POST"
                                            action="{{ route('admin.users.status', $user) }}"
                                            onsubmit="return confirm('Bạn có chắc muốn khóa tài khoản này?');"
                                        >
                                            @csrf
                                            @method('PATCH')

                                            <input
                                                type="hidden"
                                                name="status"
                                                value="LOCKED"
                                            >

                                            <button
                                                type="submit"
                                                class="icon-action-button icon-action-danger"
                                                title="Khóa tài khoản"
                                                aria-label="Khóa tài khoản {{ $user->user_code }}"
                                            >
                                                <span aria-hidden="true">
                                                    🔒
                                                </span>
                                            </button>
                                        </form>

                                    @else

                                        <form
                                            method="POST"
                                            action="{{ route('admin.users.status', $user) }}"
                                            onsubmit="return confirm('Bạn có chắc muốn mở khóa tài khoản này?');"
                                        >
                                            @csrf
                                            @method('PATCH')

                                            <input
                                                type="hidden"
                                                name="status"
                                                value="ACTIVE"
                                            >

                                            <button
                                                type="submit"
                                                class="icon-action-button icon-action-success"
                                                title="Mở khóa tài khoản"
                                                aria-label="Mở khóa tài khoản {{ $user->user_code }}"
                                            >
                                                <span aria-hidden="true">
                                                    🔓
                                                </span>
                                            </button>
                                        </form>

                                    @endif

                                @endif

                            </div>
                        </td>

                    </tr>

                @empty

                    <tr>
                        <td
                            colspan="10"
                            class="admin-empty-state"
                        >
                            Không tìm thấy người dùng phù hợp.
                        </td>
                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>

    @if ($users->hasPages())
        <div class="admin-pagination">
            {{ $users->onEachSide(1)->links() }}
        </div>
    @endif

</div>

@endsection