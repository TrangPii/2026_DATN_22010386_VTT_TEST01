@extends('admin.layouts.app')

@section('title', 'Quản lý nhà cung cấp')

@section('header')
    Quản lý nhà cung cấp

    <p class="admin-page-subtitle">
        Quản lý hồ sơ xét duyệt và quyền hoạt động của Nhà cung cấp.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">
    <div>
        <h1 class="admin-page-title">
            Danh sách nhà cung cấp
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
        action="{{ route('admin.providers.index') }}"
        class="admin-filter-form"
    >

        <div class="admin-filter-grid">

            <div class="admin-filter-field">
                <label for="user_code">
                    Mã người dùng
                </label>

                <input
                    id="user_code"
                    type="text"
                    name="user_code"
                    value="{{ request('user_code') }}"
                    class="form-control"
                    placeholder="Nhập mã người dùng"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="business_name">
                    Tên nhà cung cấp
                </label>

                <input
                    id="business_name"
                    type="text"
                    name="business_name"
                    value="{{ request('business_name') }}"
                    class="form-control"
                    placeholder="Nhập tên nhà cung cấp"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="owner_name">
                    Chủ tài khoản
                </label>

                <input
                    id="owner_name"
                    type="text"
                    name="owner_name"
                    value="{{ request('owner_name') }}"
                    class="form-control"
                    placeholder="Nhập họ tên"
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
                    value="{{ request('email') }}"
                    class="form-control"
                    placeholder="Nhập email"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="verification_status">
                    Trạng thái xác minh
                </label>

                <select
                    id="verification_status"
                    name="verification_status"
                    class="form-control"
                >
                    <option value="">
                        Tất cả
                    </option>

                    <option
                        value="PENDING"
                        @selected(
                            request('verification_status') === 'PENDING'
                        )
                    >
                        Chờ duyệt
                    </option>

                    <option
                        value="APPROVED"
                        @selected(
                            request('verification_status') === 'APPROVED'
                        )
                    >
                        Đã duyệt
                    </option>

                    <option
                        value="REJECTED"
                        @selected(
                            request('verification_status') === 'REJECTED'
                        )
                    >
                        Bị từ chối
                    </option>
                </select>
            </div>

            <div class="admin-filter-field">
                <label for="provider_status">
                    Trạng thái nhà cung cấp
                </label>

                <select
                    id="provider_status"
                    name="provider_status"
                    class="form-control"
                >
                    <option value="">
                        Tất cả
                    </option>

                    <option
                        value="ACTIVE"
                        @selected(
                            request('provider_status') === 'ACTIVE'
                        )
                    >
                        Hoạt động
                    </option>

                    <option
                        value="LOCKED"
                        @selected(
                            request('provider_status') === 'LOCKED'
                        )
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
                href="{{ route('admin.providers.index') }}"
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
                {{ $providers->total() }} bản ghi
            </span>

        </div>
    </div>

    <div class="admin-table-scroll">

        <table class="admin-data-table">

            <thead>
                <tr>
                    <th>STT</th>
                    <th>Mã người dùng</th>
                    <th>Nhà cung cấp</th>
                    <th>Chủ tài khoản</th>
                    <th>Email</th>
                    <th>Ngày đăng ký</th>
                    <th>Thao tác cuối</th>
                    <th>Xác minh</th>
                    <th>Trạng thái NCC</th>
                    <th>Thao tác</th>
                </tr>
            </thead>

            <tbody>

                @forelse ($providers as $provider)

                    <tr>

                        <td class="table-index">
                            {{ $providers->firstItem() + $loop->index }}
                        </td>

                        <td class="table-code">

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

                        </td>

                        <td class="table-provider">
                            <strong>
                                {{ $provider->business_name }}
                            </strong>
                        </td>

                        <td class="table-name">
                            {{ $provider->user?->name ?? '—' }}
                        </td>

                        <td class="table-email">
                            {{ $provider->user?->email ?? '—' }}
                        </td>

                        <td class="table-date">

                            @if ($provider->created_at)

                                <span class="date-value">
                                    {{ $provider->created_at->format('d/m/Y') }}
                                </span>

                                <span class="time-value">
                                    {{ $provider->created_at->format('H:i:s') }}
                                </span>

                            @else
                                —
                            @endif

                        </td>

                        <td class="table-date">

                            @if ($provider->updated_at)

                                <span class="date-value">
                                    {{ $provider->updated_at->format('d/m/Y') }}
                                </span>

                                <span class="time-value">
                                    {{ $provider->updated_at->format('H:i:s') }}
                                </span>

                            @else
                                —
                            @endif

                        </td>

                        <td class="table-status">

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

                                @default
                                    —
                            @endswitch

                        </td>

                        <td class="table-status">

                            @if ($provider->verification_status !== 'APPROVED')

                                <span class="status-badge status-badge-neutral">
                                    —
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

                        </td>

                        <td class="table-action">

                            <div class="table-actions">

                                <a
                                    href="{{ route(
                                        'admin.providers.show',
                                        $provider
                                    ) }}"
                                    class="icon-action-button"
                                    title="Xem chi tiết"
                                    aria-label="Xem chi tiết nhà cung cấp"
                                >
                                    <span aria-hidden="true">
                                        i
                                    </span>
                                </a>

                                @if (
                                    $provider->verification_status === 'APPROVED'
                                )

                                    @if (
                                        $provider->provider_status === 'ACTIVE'
                                    )

                                        <form
                                            method="POST"
                                            action="{{ route(
                                                'admin.providers.status',
                                                $provider
                                            ) }}"
                                            onsubmit="return confirm(
                                                'Bạn có chắc muốn khóa quyền Nhà cung cấp này?'
                                            );"
                                        >
                                            @csrf
                                            @method('PATCH')

                                            <input
                                                type="hidden"
                                                name="provider_status"
                                                value="LOCKED"
                                            >

                                            <button
                                                type="submit"
                                                class="icon-action-button icon-action-danger"
                                                title="Khóa Nhà cung cấp"
                                            >
                                                🔒
                                            </button>

                                        </form>

                                    @else

                                        <form
                                            method="POST"
                                            action="{{ route(
                                                'admin.providers.status',
                                                $provider
                                            ) }}"
                                            onsubmit="return confirm(
                                                'Bạn có chắc muốn mở khóa quyền Nhà cung cấp này?'
                                            );"
                                        >
                                            @csrf
                                            @method('PATCH')

                                            <input
                                                type="hidden"
                                                name="provider_status"
                                                value="ACTIVE"
                                            >

                                            <button
                                                type="submit"
                                                class="icon-action-button icon-action-success"
                                                title="Mở khóa Nhà cung cấp"
                                            >
                                                🔓
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
                            Không tìm thấy Nhà cung cấp phù hợp.
                        </td>
                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>

    @if ($providers->hasPages())
        <div class="admin-pagination">
            {{ $providers->onEachSide(1)->links() }}
        </div>
    @endif

</div>

@endsection