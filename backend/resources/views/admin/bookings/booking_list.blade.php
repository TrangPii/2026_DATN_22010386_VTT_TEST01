@extends('admin.layouts.app')

@section('title', 'Quản lý đơn hàng')

@section('header')
    Quản lý đơn hàng
    <p class="admin-page-subtitle">
        Theo dõi và tra cứu các đơn đặt dịch vụ trên hệ thống.
    </p>
@endsection

@section('content')
<div class="admin-page-heading">
    <div>
        <h1 class="admin-page-title">Danh sách đơn hàng</h1>
    </div>
</div>

@if (session('success'))
    <div class="alert alert-success">{{ session('success') }}</div>
@endif

@if (session('error'))
    <div class="alert alert-error">{{ session('error') }}</div>
@endif

@if ($errors->any())
    <div class="alert alert-error">{{ $errors->first() }}</div>
@endif

<div class="admin-section-card">
    <form method="GET"
          action="{{ route('admin.bookings.index') }}"
          class="admin-filter-form">

        <div class="admin-filter-grid">
            <div class="admin-filter-field">
                <label for="booking_code">Mã đơn hàng</label>
                <input
                    id="booking_code"
                    type="text"
                    name="booking_code"
                    class="form-control"
                    value="{{ request('booking_code') }}"
                    placeholder="Nhập mã đơn hàng"
                    maxlength="50"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="user_code">Mã người dùng</label>
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
                <label for="service_name">Dịch vụ</label>
                <input
                    id="service_name"
                    type="text"
                    name="service_name"
                    class="form-control"
                    value="{{ request('service_name') }}"
                    placeholder="Nhập tên dịch vụ"
                    maxlength="100"
                    autocomplete="off"
                >
            </div>

            <div class="admin-filter-field">
                <label for="provider_search">Nhà cung cấp</label>

                <input
                    id="provider_search"
                    type="text"
                    class="form-control filter-combobox-input"
                    list="provider_options"
                    placeholder="Chọn hoặc nhập Nhà cung cấp"
                    autocomplete="off"
                    value="{{
                        optional(
                            $providers->firstWhere(
                                'id',
                                (int) request('provider_id')
                            )
                        )->providerProfile?->business_name
                        ??
                        optional(
                            $providers->firstWhere(
                                'id',
                                (int) request('provider_id')
                            )
                        )->name
                    }}"
                >

                <input
                    id="provider_id"
                    type="hidden"
                    name="provider_id"
                    value="{{ request('provider_id') }}"
                >

                <datalist id="provider_options">
                    @foreach ($providers as $provider)
                        <option
                            value="{{ $provider->providerProfile?->business_name ?? $provider->name }}"
                            data-id="{{ $provider->id }}"
                        ></option>
                    @endforeach
                </datalist>
            </div>

            <div class="admin-filter-field">
                <label for="status">Trạng thái</label>

                <select id="status"
                        name="status"
                        class="form-control">
                    <option value="">Tất cả</option>
                    <option value="PENDING"
                        @selected(request('status') === 'PENDING')>
                        Chờ xác nhận
                    </option>
                    <option value="ACCEPTED"
                        @selected(request('status') === 'ACCEPTED')>
                        Đã nhận
                    </option>
                    <option value="IN_PROGRESS"
                        @selected(request('status') === 'IN_PROGRESS')>
                        Đang thực hiện
                    </option>
                    <option value="COMPLETED"
                        @selected(request('status') === 'COMPLETED')>
                        Hoàn thành
                    </option>
                    <option value="REJECTED"
                        @selected(request('status') === 'REJECTED')>
                        Từ chối
                    </option>
                    <option value="CANCELLED"
                        @selected(request('status') === 'CANCELLED')>
                        Đã hủy
                    </option>
                </select>
            </div>
        </div>

        <div class="admin-filter-actions">
            <button type="submit" class="btn btn-primary">
                Tìm kiếm
            </button>

            <a href="{{ route('admin.bookings.index') }}"
               class="btn btn-secondary">
                Thiết lập lại
            </a>
        </div>
    </form>
</div>

<div class="admin-section-card">
    <div class="admin-table-header">
        <div class="admin-table-header2">
            <h4 class="admin-section-title">Bảng tìm kiếm</h4>
            <span class="admin-result-count">
                {{ $bookings->total() }} bản ghi
            </span>
        </div>
    </div>

    <div class="admin-table-scroll">
        <table class="admin-data-table admin-booking-table">
            <thead>
                <tr>
                    <th>STT</th>
                    <th>Mã đơn hàng</th>
                    <th>Mã người dùng</th>
                    <th>Tên khách hàng</th>
                    <th>Dịch vụ</th>
                    <th>Nhà cung cấp</th>
                    <th>Tổng đơn</th>
                    <th>Ngày đặt</th>
                    <th>Cập nhật cuối</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>

            <tbody>
                @forelse ($bookings as $booking)
                    <tr>
                        <td class="table-index">
                            {{ $bookings->firstItem() + $loop->index }}
                        </td>

                        <td class="table-code">
                            {{ $booking->booking_code }}
                        </td>

                        <td class="table-code">
                            @if ($booking->customer)
                                <a href="{{ route('admin.users.show', $booking->customer) }}"
                                   class="table-link">
                                    {{ $booking->customer->user_code }}
                                </a>
                            @else
                                —
                            @endif
                        </td>

                        <td class="table-name">
                            @if ($booking->customer)
                                <a href="{{ route('admin.users.show', $booking->customer) }}"
                                   class="table-link">
                                    {{ $booking->customer_name }}
                                </a>
                            @else
                                {{ $booking->customer_name }}
                            @endif
                        </td>

                        <td class="table-name">
                            @if ($booking->service)
                                <a href="{{ route('admin.services.show', $booking->service) }}"
                                   class="table-link">
                                    {{ $booking->service_name }}
                                </a>
                            @else
                                {{ $booking->service_name }}
                            @endif
                        </td>

                        <td class="table-provider">
                            @if ($booking->provider?->providerProfile)
                                <a href="{{ route('admin.providers.show', $booking->provider->providerProfile) }}"
                                   class="table-link">
                                    {{ $booking->provider->providerProfile->business_name }}
                                </a>
                            @else
                                {{ $booking->provider?->name ?? '—' }}
                            @endif
                        </td>

                        <td class="table-price">
                            <strong>
                                {{ number_format(
                                    (float) $booking->total_amount,
                                    0,
                                    ',',
                                    '.'
                                ) }} đ
                            </strong>
                        </td>

                        <td class="table-date">
                            @if ($booking->created_at)
                                <span class="date-value">
                                    {{ $booking->created_at->format('d/m/Y') }}
                                </span>
                                <span class="time-value">
                                    {{ $booking->created_at->format('H:i:s') }}
                                </span>
                            @else
                                —
                            @endif
                        </td>

                        <td class="table-date">
                            @if ($booking->updated_at)
                                <span class="date-value">
                                    {{ $booking->updated_at->format('d/m/Y') }}
                                </span>
                                <span class="time-value">
                                    {{ $booking->updated_at->format('H:i:s') }}
                                </span>
                            @else
                                —
                            @endif
                        </td>

                        <td class="table-status">
                            @switch($booking->status)
                                @case('PENDING')
                                    <span class="status-badge status-badge-warning">
                                        Chờ xác nhận
                                    </span>
                                    @break

                                @case('ACCEPTED')
                                    <span class="status-badge status-badge-info">
                                        Đã nhận
                                    </span>
                                    @break

                                @case('IN_PROGRESS')
                                    <span class="status-badge status-badge-info">
                                        Đang thực hiện
                                    </span>
                                    @break

                                @case('COMPLETED')
                                    <span class="status-badge status-badge-success">
                                        Hoàn thành
                                    </span>
                                    @break

                                @case('REJECTED')
                                    <span class="status-badge status-badge-danger">
                                        Từ chối
                                    </span>
                                    @break

                                @case('CANCELLED')
                                    <span class="status-badge status-badge-danger">
                                        Đã hủy
                                    </span>
                                    @break

                                @default
                                    <span class="status-badge status-badge-neutral">
                                        {{ $booking->status }}
                                    </span>
                            @endswitch
                        </td>

                        <td class="table-action">
                            <div class="table-actions">
                                <a href="{{ route('admin.bookings.show', $booking) }}"
                                   class="icon-action-button"
                                   title="Xem chi tiết"
                                   aria-label="Xem chi tiết đơn {{ $booking->booking_code }}">
                                    i
                                </a>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="11"
                            class="admin-empty-state">
                            Không tìm thấy đơn hàng phù hợp.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="admin-table-footer">
        <div>
            @if ($bookings->hasPages())
                <div class="admin-pagination">
                    {{ $bookings->onEachSide(1)->links() }}
                </div>
            @endif
        </div>

        <form method="GET"
              action="{{ route('admin.bookings.index') }}"
              class="admin-per-page-form">

            <input type="hidden"
                   name="booking_code"
                   value="{{ request('booking_code') }}">

            <input type="hidden"
                   name="user_code"
                   value="{{ request('user_code') }}">

            <input type="hidden"
                   name="service_name"
                   value="{{ request('service_name') }}">

            <input type="hidden"
                   name="provider_id"
                   value="{{ request('provider_id') }}">

            <input type="hidden"
                   name="status"
                   value="{{ request('status') }}">
        </form>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const input = document.getElementById('provider_search');
    const hidden = document.getElementById('provider_id');
    const datalist = document.getElementById('provider_options');

    if (!input || !hidden || !datalist) {
        return;
    }

    const syncProvider = function () {
        const value = input.value.trim();

        const matched = Array.from(datalist.options).find(
            option => option.value === value
        );

        hidden.value = matched
            ? matched.dataset.id
            : '';
    };

    input.addEventListener('input', syncProvider);
    input.addEventListener('change', syncProvider);
});
</script>
@endsection