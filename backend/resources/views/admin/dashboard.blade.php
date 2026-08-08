@extends('admin.layouts.app')

@section('title', 'Dashboard')
@section('header', 'Dashboard')

@section('content')

<h1 class="page-title">
    Tổng quan hệ thống
</h1>

<div class="stats-grid">

    <div class="stat-card">
        <div class="stat-label">
            Người dùng
        </div>

        <div class="stat-value">
            {{ $stats['users'] }}
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-label">
            Khách hàng
        </div>

        <div class="stat-value">
            {{ $stats['customers'] }}
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-label">
            Nhà cung cấp
        </div>

        <div class="stat-value">
            {{ $stats['providers'] }}
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-label">
            Provider chờ duyệt
        </div>

        <div class="stat-value">
            {{ $stats['pending_providers'] }}
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-label">
            Danh mục
        </div>

        <div class="stat-value">
            {{ $stats['categories'] }}
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-label">
            Dịch vụ
        </div>

        <div class="stat-value">
            {{ $stats['services'] }}
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-label">
            Booking
        </div>

        <div class="stat-value">
            {{ $stats['bookings'] }}
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-label">
            Booking hoàn thành
        </div>

        <div class="stat-value">
            {{ $stats['completed_bookings'] }}
        </div>
    </div>

</div>

<div class="card">

    <div class="card-header">
        Booking gần đây
    </div>

    <div style="overflow-x:auto;">

        <table>

            <thead>
            <tr>
                <th>Mã</th>
                <th>Dịch vụ</th>
                <th>Khách hàng</th>
                <th>Provider</th>
                <th>Trạng thái</th>
                <th>Tổng tiền</th>
            </tr>
            </thead>

            <tbody>

            @forelse(
                $recentBookings
                as $booking
            )

                <tr>

                    <td>
                        {{ $booking->booking_code }}
                    </td>

                    <td>
                        {{ $booking->service_name }}
                    </td>

                    <td>
                        {{ $booking->customer?->name }}
                    </td>

                    <td>
                        {{ $booking->provider?->name }}
                    </td>

                    <td>
                        <span class="badge">
                            {{ $booking->status }}
                        </span>
                    </td>

                    <td>
                        {{ number_format(
                            $booking->total_amount,
                            0,
                            ',',
                            '.'
                        ) }} ₫
                    </td>

                </tr>

            @empty

                <tr>
                    <td colspan="6">
                        Chưa có booking.
                    </td>
                </tr>

            @endforelse

            </tbody>

        </table>

    </div>

</div>

@endsection