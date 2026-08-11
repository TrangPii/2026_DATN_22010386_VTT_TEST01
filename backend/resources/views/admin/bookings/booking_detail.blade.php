@extends('admin.layouts.app')

@section('title', 'Chi tiết đơn đặt dịch vụ')

@section('header')
    Quản lý đơn đặt dịch vụ

    <p class="admin-page-subtitle">
        Xem thông tin và lịch sử xử lý đơn đặt dịch vụ.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">

    <div>

        <h1 class="admin-page-title">
            Chi tiết đơn đặt dịch vụ
        </h1>

        <p class="admin-page-subtitle">
            {{ $booking->booking_code }}
        </p>

    </div>

    <a
        href="{{ route('admin.bookings.index') }}"
        class="btn btn-secondary"
    >
        ← Quay lại
    </a>

</div>


<div class="admin-section-card">

    <div class="admin-detail-header">

        <h4 class="admin-section-title">
            Thông tin đơn
        </h4>

    </div>


    <div class="detail-grid detail-grid-padding">


        <div class="detail-item">

            <div class="detail-label">
                Mã đơn
            </div>

            <div class="detail-value">
                {{ $booking->booking_code }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Trạng thái
            </div>

            <div class="detail-value">

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
                            Bị từ chối
                        </span>
                        @break

                    @case('CANCELLED')
                        <span class="status-badge status-badge-danger">
                            Đã hủy
                        </span>
                        @break

                @endswitch

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Dịch vụ
            </div>

            <div class="detail-value">

                @if ($booking->service)

                    <a
                        href="{{ route(
                            'admin.services.show',
                            $booking->service
                        ) }}"
                        class="table-link"
                    >
                        {{ $booking->service_name }}
                    </a>

                @else

                    {{ $booking->service_name }}

                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Đơn giá
            </div>

            <div class="detail-value">
                {{ number_format(
                    (float) $booking->unit_price,
                    0,
                    ',',
                    '.'
                ) }}
                đ
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Số lượng
            </div>

            <div class="detail-value">
                {{ $booking->quantity }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Tổng tiền
            </div>

            <div class="detail-value">
                <strong>
                    {{ number_format(
                        (float) $booking->total_amount,
                        0,
                        ',',
                        '.'
                    ) }}
                    đ
                </strong>
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Thời gian dịch vụ
            </div>

            <div class="detail-value">

                @if ($booking->booking_date)

                    {{ $booking->booking_date->format('d/m/Y') }}
                    {{ $booking->booking_time }}

                @else
                    —
                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Ngày tạo đơn
            </div>

            <div class="detail-value">

                @if ($booking->created_at)

                    {{ $booking->created_at->format(
                        'd/m/Y H:i:s'
                    ) }}

                @else
                    —
                @endif

            </div>

        </div>

    </div>

</div>


<div class="admin-section-card">

    <div class="admin-detail-header">

        <h4 class="admin-section-title">
            Khách hàng
        </h4>

    </div>


    <div class="detail-grid detail-grid-padding">

        <div class="detail-item">

            <div class="detail-label">
                Mã người dùng
            </div>

            <div class="detail-value">

                @if ($booking->customer)

                    <a
                        href="{{ route(
                            'admin.users.show',
                            $booking->customer
                        ) }}"
                        class="table-link"
                    >
                        {{ $booking->customer->user_code }}
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
                {{ $booking->customer_name }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Số điện thoại
            </div>

            <div class="detail-value">
                {{ $booking->customer_phone ?: '—' }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Email
            </div>

            <div class="detail-value">
                {{ $booking->customer?->email ?? '—' }}
            </div>

        </div>


        <div class="detail-item admin-detail-field-wide">

            <div class="detail-label">
                Địa chỉ dịch vụ
            </div>

            <div class="detail-value">
                {{ $booking->service_address ?: '—' }}
            </div>

        </div>

    </div>


    <div class="detail-description">

        <div class="detail-label">
            Ghi chú
        </div>

        <div class="detail-value">
            {{ $booking->note ?: 'Không có ghi chú' }}
        </div>

    </div>

</div>


<div class="admin-section-card">

    <div class="admin-detail-header">

        <h4 class="admin-section-title">
            Nhà cung cấp
        </h4>

    </div>


    <div class="detail-grid detail-grid-padding">

        <div class="detail-item">

            <div class="detail-label">
                Tên Nhà cung cấp
            </div>

            <div class="detail-value">

                @if ($booking->provider?->providerProfile)

                    <a
                        href="{{ route(
                            'admin.providers.show',
                            $booking->provider->providerProfile
                        ) }}"
                        class="table-link"
                    >
                        {{
                            $booking
                                ->provider
                                ->providerProfile
                                ->business_name
                        }}
                    </a>

                @else
                    —
                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Mã người dùng
            </div>

            <div class="detail-value">

                @if ($booking->provider)

                    <a
                        href="{{ route(
                            'admin.users.show',
                            $booking->provider
                        ) }}"
                        class="table-link"
                    >
                        {{ $booking->provider->user_code }}
                    </a>

                @else
                    —
                @endif

            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Chủ tài khoản
            </div>

            <div class="detail-value">
                {{ $booking->provider?->name ?? '—' }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Email
            </div>

            <div class="detail-value">
                {{ $booking->provider?->email ?? '—' }}
            </div>

        </div>


        <div class="detail-item">

            <div class="detail-label">
                Trạng thái xác minh
            </div>

            <div class="detail-value">

                @switch(
                    $booking
                        ->provider
                        ?->providerProfile
                        ?->verification_status
                )

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

                        <span class="status-badge status-badge-neutral">
                            —
                        </span>

                @endswitch

            </div>

        </div>

    </div>

</div>


@if (
    $booking->rejection_reason ||
    $booking->cancellation_reason
)

    <div class="admin-section-card">

        <div class="admin-detail-header">

            <h4 class="admin-section-title">
                Lý do kết thúc đơn
            </h4>

        </div>


        <div class="detail-grid detail-grid-padding">

            @if ($booking->rejection_reason)

                <div class="detail-item">

                    <div class="detail-label">
                        Nhà cung cấp từ chối đơn
                    </div>

                    <div class="detail-value">
                        {{ $booking->rejection_reason }}
                    </div>

                </div>

            @endif


            @if ($booking->cancellation_reason)

                <div class="detail-item">

                    <div class="detail-label">
                        Khách hàng hủy đơn
                    </div>

                    <div class="detail-value">
                        {{ $booking->cancellation_reason }}
                    </div>

                </div>

            @endif

        </div>

    </div>

@endif


<div class="admin-section-card">

    <div class="admin-detail-header">

        <h4 class="admin-section-title">
            Lịch sử trạng thái
        </h4>

    </div>


    <div class="admin-table-scroll">

        <table class="admin-data-table admin-history-table">

            <thead>

                <tr>
                    <th>Thời gian</th>
                    <th>Trạng thái trước</th>
                    <th>Trạng thái mới</th>
                    <th>Người thực hiện</th>
                    <th>Ghi chú</th>
                </tr>

            </thead>


            <tbody>

                @forelse (
                    $booking->statusHistories
                    as $history
                )

                    <tr>

                        <td class="table-date">

                            @if ($history->created_at)

                                <span class="date-value">
                                    {{ $history->created_at->format('d/m/Y') }}
                                </span>

                                <span class="time-value">
                                    {{ $history->created_at->format('H:i:s') }}
                                </span>

                            @else
                                —
                            @endif

                        </td>


                        <td class="table-status">

                            @switch($history->old_status)

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
                                        Bị từ chối
                                    </span>
                                    @break

                                @case('CANCELLED')
                                    <span class="status-badge status-badge-danger">
                                        Đã hủy
                                    </span>
                                    @break

                                @default
                                    —
                            @endswitch

                        </td>


                        <td class="table-status">

                            @switch($history->new_status)

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
                                        Bị từ chối
                                    </span>
                                    @break

                                @case('CANCELLED')
                                    <span class="status-badge status-badge-danger">
                                        Đã hủy
                                    </span>
                                    @break

                                @default
                                    {{ $history->new_status }}
                            @endswitch

                        </td>


                        <td class="table-name">

                            {{ $history->changedByUser?->name
                                ?? 'Hệ thống'
                            }}

                        </td>


                        <td class="table-description">
                            {{ $history->note ?: '—' }}
                        </td>

                    </tr>

                @empty

                    <tr>

                        <td
                            colspan="5"
                            class="admin-empty-state"
                        >
                            Chưa có lịch sử trạng thái.
                        </td>

                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>

</div>


@if ($booking->review)

    <div class="admin-section-card">

        <div class="admin-detail-header">

            <h4 class="admin-section-title">
                Đánh giá của khách hàng
            </h4>

        </div>


        <div class="detail-grid detail-grid-padding">

            <div class="detail-item">

                <div class="detail-label">
                    Số sao
                </div>

                <div class="detail-value">
                    {{ $booking->review->rating }} / 5
                </div>

            </div>


            <div class="detail-item">

                <div class="detail-label">
                    Trạng thái đánh giá
                </div>

                <div class="detail-value">
                    {{ $booking->review->status }}
                </div>

            </div>

        </div>


        <div class="detail-description">

            <div class="detail-label">
                Nội dung
            </div>

            <div class="detail-value">
                {{
                    $booking->review->comment
                    ?: 'Không có đánh giá'
                }}
            </div>

        </div>

    </div>

@endif

@endsection