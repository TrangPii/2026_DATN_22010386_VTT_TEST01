@extends('admin.layouts.app')

@section('title', 'Quản lý đơn đặt dịch vụ')

@section('content')
    <h1 class="page-title">
        Quản lý đơn đặt dịch vụ
    </h1>

    @if ($errors->any())
        <div class="alert alert-error">
            {{ $errors->first() }}
        </div>
    @endif

    <form
        method="GET"
        action="{{ route('admin.bookings.index') }}"
        class="filter-bar"
    >
        <input
            type="text"
            name="search"
            value="{{ request('search') }}"
            placeholder="Mã đơn, khách hàng, dịch vụ..."
            class="form-control filter-search"
        >

        <select
            name="status"
            class="form-control"
        >
            <option value="">
                Tất cả trạng thái
            </option>

            <option
                value="PENDING"
                @selected(request('status') === 'PENDING')
            >
                Chờ xác nhận
            </option>

            <option
                value="ACCEPTED"
                @selected(request('status') === 'ACCEPTED')
            >
                Đã nhận
            </option>

            <option
                value="IN_PROGRESS"
                @selected(request('status') === 'IN_PROGRESS')
            >
                Đang thực hiện
            </option>

            <option
                value="COMPLETED"
                @selected(request('status') === 'COMPLETED')
            >
                Hoàn thành
            </option>

            <option
                value="REJECTED"
                @selected(request('status') === 'REJECTED')
            >
                Bị từ chối
            </option>

            <option
                value="CANCELLED"
                @selected(request('status') === 'CANCELLED')
            >
                Đã hủy
            </option>
        </select>

        <button
            type="submit"
            class="btn btn-primary"
        >
            Lọc
        </button>

        <a
            href="{{ route('admin.bookings.index') }}"
            class="btn btn-secondary"
        >
            Đặt lại
        </a>
    </form>

    <div class="card">
        <div class="card-header">
            Danh sách đơn đặt dịch vụ
        </div>

        <table>
            <thead>
                <tr>
                    <th>Mã đơn</th>
                    <th>Dịch vụ</th>
                    <th>Khách hàng</th>
                    <th>Nhà cung cấp</th>
                    <th>Tổng tiền</th>
                    <th>Ngày đặt</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>

            <tbody>
                @forelse ($bookings as $booking)
                    <tr>
                        <td>
                            <strong>
                                {{ $booking->booking_code }}
                            </strong>
                        </td>

                        <td>
                            {{ $booking->service_name }}
                        </td>

                        <td>
                            {{ $booking->customer_name }}
                        </td>

                        <td>
                            {{ $booking->provider
                                ?->providerProfile
                                ?->business_name
                                ?? $booking->provider?->name
                                ?? 'N/A' }}
                        </td>

                        <td>
                            {{ number_format(
                                (float) $booking->total_amount,
                                0,
                                ',',
                                '.'
                            ) }}
                            đ
                        </td>

                        <td>
                            {{ $booking->booking_date?->format(
                                'd/m/Y'
                            ) }}

                            {{ $booking->booking_time }}
                        </td>

                        <td>
                            <span class="badge">
                                @switch($booking->status)
                                    @case('PENDING')
                                        Chờ xác nhận
                                        @break

                                    @case('ACCEPTED')
                                        Đã nhận
                                        @break

                                    @case('IN_PROGRESS')
                                        Đang thực hiện
                                        @break

                                    @case('COMPLETED')
                                        Hoàn thành
                                        @break

                                    @case('REJECTED')
                                        Bị từ chối
                                        @break

                                    @case('CANCELLED')
                                        Đã hủy
                                        @break
                                @endswitch
                            </span>
                        </td>

                        <td>
                            <a
                                href="{{ route(
                                    'admin.bookings.show',
                                    $booking
                                ) }}"
                                class="btn btn-secondary"
                            >
                                Xem
                            </a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="8">
                            Chưa có đơn phù hợp.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        @if ($bookings->hasPages())
            <div class="pagination-wrapper">
                {{ $bookings->links() }}
            </div>
        @endif
    </div>
@endsection