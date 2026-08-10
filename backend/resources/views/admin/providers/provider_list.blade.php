@extends('admin.layouts.app')

@section('title', 'Quản lý Nhà cung cấp')

@section('content')
    <h1 class="page-title">
        Quản lý Nhà cung cấp
    </h1>

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

    <form
        method="GET"
        action="{{ route('admin.providers.index') }}"
        class="filter-bar"
    >
        <input
            type="text"
            name="search"
            value="{{ request('search') }}"
            placeholder="Tên nhà cung cấp, người dùng, email..."
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
                Chờ duyệt
            </option>

            <option
                value="APPROVED"
                @selected(request('status') === 'APPROVED')
            >
                Đã duyệt
            </option>

            <option
                value="REJECTED"
                @selected(request('status') === 'REJECTED')
            >
                Bị từ chối
            </option>
        </select>

        <button
            type="submit"
            class="btn btn-primary"
        >
            Lọc
        </button>

        <a
            href="{{ route('admin.providers.index') }}"
            class="btn btn-secondary"
        >
            Đặt lại
        </a>
    </form>

    <div class="card">
        <div class="card-header">
            Danh sách hồ sơ Nhà cung cấp
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nhà cung cấp</th>
                    <th>Người dùng</th>
                    <th>Email</th>
                    <th>Kinh nghiệm</th>
                    <th>Trạng thái</th>
                    <th>Ngày gửi</th>
                    <th>Thao tác</th>
                </tr>
            </thead>

            <tbody>
                @forelse ($providers as $provider)
                    <tr>
                        <td>
                            #{{ $provider->id }}
                        </td>

                        <td>
                            <strong>
                                {{ $provider->business_name }}
                            </strong>
                        </td>

                        <td>
                            {{ $provider->user?->name ?? 'N/A' }}
                        </td>

                        <td>
                            {{ $provider->user?->email ?? 'N/A' }}
                        </td>

                        <td>
                            {{ $provider->experience_years }} năm
                        </td>

                        <td>
                            @switch($provider->verification_status)
                                @case('APPROVED')
                                    <span class="badge">
                                        Đã duyệt
                                    </span>
                                    @break

                                @case('PENDING')
                                    <span class="badge">
                                        Chờ duyệt
                                    </span>
                                    @break

                                @case('REJECTED')
                                    <span class="badge">
                                        Bị từ chối
                                    </span>
                                    @break

                                @default
                                    <span class="badge">
                                        {{ $provider->verification_status }}
                                    </span>
                            @endswitch
                        </td>

                        <td>
                            {{ $provider->created_at?->format('d/m/Y H:i') ?? 'N/A' }}
                        </td>

                        <td>
                            <div class="actions">
                                <a
                                    href="{{ route(
                                        'admin.providers.show',
                                        $provider
                                    ) }}"
                                    class="btn btn-primary"
                                >
                                    Xem
                                </a>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="8">
                            Chưa có hồ sơ Nhà cung cấp phù hợp.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        @if ($providers->hasPages())
            <div class="pagination-wrapper">
                {{ $providers->links() }}
            </div>
        @endif
    </div>
@endsection