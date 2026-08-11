@extends('admin.layouts.app')

@section('title', 'Dashboard')

@section('header')
    Dashboard
    <p class="admin-page-subtitle">
        Tổng quan nhanh tình trạng hoạt động của hệ thống.
    </p>
@endsection

@section('content')
<div class="admin-page-heading">
    <div>
        <h1 class="admin-page-title">Tổng quan hệ thống</h1>
    </div>
</div>

<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-label">Người dùng</div>
        <div class="stat-value">{{ $stats['users'] }}</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Khách hàng</div>
        <div class="stat-value">{{ $stats['customers'] }}</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Nhà cung cấp</div>
        <div class="stat-value">{{ $stats['providers'] }}</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Nhà cung cấp chờ duyệt</div>
        <div class="stat-value">{{ $stats['pending_providers'] }}</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Danh mục</div>
        <div class="stat-value">{{ $stats['categories'] }}</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Dịch vụ</div>
        <div class="stat-value">{{ $stats['services'] }}</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Đơn hàng</div>
        <div class="stat-value">{{ $stats['bookings'] }}</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Đơn hoàn thành</div>
        <div class="stat-value">{{ $stats['completed_bookings'] }}</div>
    </div>
</div>

<div class="admin-section-card">
    <div class="admin-table-header">
        <div class="admin-table-header2">
            <h4 class="admin-section-title">Đơn hàng gần đây</h4>

            <a href="{{ route('admin.bookings.index') }}"
               class="table-link">
                Xem tất cả
            </a>
        </div>
    </div>

    <div class="admin-table-scroll">
        <table class="admin-data-table dashboard-booking-table">
            <thead>
                <tr>
                    <th>Mã đơn hàng</th>
                    <th>Dịch vụ</th>
                    <th>Khách hàng</th>
                    <th>Nhà cung cấp</th>
                    <th>Trạng thái</th>
                    <th>Tổng đơn</th>
                </tr>
            </thead>

            <tbody>
                @forelse ($recentBookings as $booking)
                    <tr>
                        <td class="table-code">
                            <a href="{{ route('admin.bookings.show', $booking) }}"
                               class="table-link">
                                {{ $booking->booking_code }}
                            </a>
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

                        <td class="table-name">
                            @if ($booking->customer)
                                <a href="{{ route('admin.users.show', $booking->customer) }}"
                                   class="table-link">
                                    {{ $booking->customer->name }}
                                </a>
                            @else
                                —
                            @endif
                        </td>

                        <td class="table-provider">
                            @if ($booking->provider?->providerProfile)
                                <a href="{{ route(
                                    'admin.providers.show',
                                    $booking->provider->providerProfile
                                ) }}"
                                   class="table-link">
                                    {{ $booking->provider->providerProfile->business_name }}
                                </a>
                            @else
                                {{ $booking->provider?->name ?? '—' }}
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
                    </tr>
                @empty
                    <tr>
                        <td colspan="6"
                            class="admin-empty-state">
                            Chưa có đơn hàng.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection