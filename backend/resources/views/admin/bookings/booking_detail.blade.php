@extends('admin.layouts.app')

@section('title', 'Chi tiết đơn đặt dịch vụ')

@section('content')
    <div
        class="actions"
        style="justify-content: space-between; margin-bottom: 24px;"
    >
        <h1
            class="page-title"
            style="margin-bottom: 0;"
        >
            Chi tiết đơn
        </h1>

        <a
            href="{{ route('admin.bookings.index') }}"
            class="btn btn-secondary"
        >
            Quay lại
        </a>
    </div>

    <div class="card">
        <div class="card-header">
            {{ $booking->booking_code }}
        </div>

        <div style="padding: 20px;">
            <div class="detail-grid">
                <div class="detail-item">
                    <div class="detail-label">
                        Trạng thái
                    </div>

                    <div class="detail-value">
                        <span class="badge">
                            {{ $booking->status }}
                        </span>
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Dịch vụ
                    </div>

                    <div class="detail-value">
                        {{ $booking->service_name }}
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
                        {{ number_format(
                            (float) $booking->total_amount,
                            0,
                            ',',
                            '.'
                        ) }}
                        đ
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Thời gian dịch vụ
                    </div>

                    <div class="detail-value">
                        {{ $booking->booking_date?->format(
                            'd/m/Y'
                        ) }}

                        {{ $booking->booking_time }}
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            Khách hàng
        </div>

        <div style="padding: 20px;">
            <div class="detail-grid">
                <div class="detail-item">
                    <div class="detail-label">
                        Họ tên
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
                        {{ $booking->customer_phone }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Email tài khoản
                    </div>

                    <div class="detail-value">
                        {{ $booking->customer?->email ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Địa chỉ dịch vụ
                    </div>

                    <div class="detail-value">
                        {{ $booking->service_address }}
                    </div>
                </div>
            </div>

            <div
                class="detail-item"
                style="margin-top: 16px;"
            >
                <div class="detail-label">
                    Ghi chú
                </div>

                <div>
                    {{ $booking->note ?: 'Không có' }}
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            Nhà cung cấp
        </div>

        <div style="padding: 20px;">
            <div class="detail-grid">
                <div class="detail-item">
                    <div class="detail-label">
                        Tên Nhà cung cấp
                    </div>

                    <div class="detail-value">
                        {{ $booking->provider
                            ?->providerProfile
                            ?->business_name
                            ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Chủ tài khoản
                    </div>

                    <div class="detail-value">
                        {{ $booking->provider?->name ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Email
                    </div>

                    <div class="detail-value">
                        {{ $booking->provider?->email ?? 'N/A' }}
                    </div>
                </div>

                <div class="detail-item">
                    <div class="detail-label">
                        Trạng thái xác minh
                    </div>

                    <div class="detail-value">
                        {{ $booking->provider
                            ?->providerProfile
                            ?->verification_status
                            ?? 'N/A' }}
                    </div>
                </div>
            </div>
        </div>
    </div>

    @if (
        $booking->rejection_reason ||
        $booking->cancellation_reason
    )
        <div class="card">
            <div class="card-header">
                Lý do
            </div>

            <div style="padding: 20px;">
                @if ($booking->rejection_reason)
                    <div class="detail-item">
                        <div class="detail-label">
                            Lý do từ chối
                        </div>

                        <div>
                            {{ $booking->rejection_reason }}
                        </div>
                    </div>
                @endif

                @if ($booking->cancellation_reason)
                    <div
                        class="detail-item"
                        style="margin-top: 12px;"
                    >
                        <div class="detail-label">
                            Lý do hủy
                        </div>

                        <div>
                            {{ $booking->cancellation_reason }}
                        </div>
                    </div>
                @endif
            </div>
        </div>
    @endif

    <div class="card">
        <div class="card-header">
            Lịch sử trạng thái
        </div>

        <table>
            <thead>
                <tr>
                    <th>Thời gian</th>
                    <th>Từ</th>
                    <th>Sang</th>
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
                        <td>
                            {{ $history->created_at?->format(
                                'd/m/Y H:i'
                            ) }}
                        </td>

                        <td>
                            {{ $history->old_status ?? '-' }}
                        </td>

                        <td>
                            {{ $history->new_status }}
                        </td>

                        <td>
                            {{ $history->changedByUser?->name
                                ?? 'Hệ thống' }}
                        </td>

                        <td>
                            {{ $history->note ?? '-' }}
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5">
                            Chưa có lịch sử trạng thái.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if ($booking->review)
        <div class="card">
            <div class="card-header">
                Đánh giá của khách hàng
            </div>

            <div style="padding: 20px;">
                <div class="detail-grid">
                    <div class="detail-item">
                        <div class="detail-label">
                            Số sao
                        </div>

                        <div class="detail-value">
                            {{ $booking->review->rating }}
                            / 5
                        </div>
                    </div>

                    <div class="detail-item">
                        <div class="detail-label">
                            Trạng thái
                        </div>

                        <div class="detail-value">
                            {{ $booking->review->status }}
                        </div>
                    </div>
                </div>

                <div
                    class="detail-item"
                    style="margin-top: 16px;"
                >
                    <div class="detail-label">
                        Nội dung
                    </div>

                    <div>
                        {{ $booking->review->comment
                            ?: 'Không có nhận xét' }}
                    </div>
                </div>
            </div>
        </div>
    @endif
@endsection