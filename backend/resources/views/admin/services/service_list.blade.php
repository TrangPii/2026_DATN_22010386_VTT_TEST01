@extends('admin.layouts.app')

@section('title', 'Quản lý dịch vụ')

@section('content')
    <h1 class="page-title">
        Quản lý dịch vụ
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
        action="{{ route('admin.services.index') }}"
        class="filter-bar"
    >
        <input
            type="text"
            name="search"
            value="{{ request('search') }}"
            placeholder="Tên dịch vụ, Provider..."
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
                value="ACTIVE"
                @selected(request('status') === 'ACTIVE')
            >
                Đang hoạt động
            </option>

            <option
                value="INACTIVE"
                @selected(request('status') === 'INACTIVE')
            >
                Tạm ngừng
            </option>
        </select>

        <select
            name="category_id"
            class="form-control"
        >
            <option value="">
                Tất cả danh mục
            </option>

            @foreach ($categories as $category)
                <option
                    value="{{ $category->id }}"
                    @selected(
                        (string) request('category_id') ===
                        (string) $category->id
                    )
                >
                    {{ $category->name }}
                </option>
            @endforeach
        </select>

        <select
            name="provider_id"
            class="form-control"
        >
            <option value="">
                Tất cả Nhà cung cấp
            </option>

            @foreach ($providers as $provider)
                <option
                    value="{{ $provider->id }}"
                    @selected(
                        (string) request('provider_id') ===
                        (string) $provider->id
                    )
                >
                    {{ $provider->providerProfile?->business_name
                        ?? $provider->name }}
                </option>
            @endforeach
        </select>

        <button
            type="submit"
            class="btn btn-primary"
        >
            Lọc
        </button>

        <a
            href="{{ route('admin.services.index') }}"
            class="btn btn-secondary"
        >
            Đặt lại
        </a>
    </form>

    <div class="card">
        <div class="card-header">
            Danh sách dịch vụ
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Dịch vụ</th>
                    <th>Danh mục</th>
                    <th>Nhà cung cấp</th>
                    <th>Giá</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>

            <tbody>
                @forelse ($services as $service)
                    <tr>
                        <td>
                            #{{ $service->id }}
                        </td>

                        <td>
                            <strong>
                                {{ $service->name }}
                            </strong>
                        </td>

                        <td>
                            {{ $service->category?->name ?? 'N/A' }}
                        </td>

                        <td>
                            {{ $service->provider
                                ?->providerProfile
                                ?->business_name
                                ?? $service->provider?->name
                                ?? 'N/A' }}
                        </td>

                        <td>
                            {{ number_format(
                                (float) $service->price,
                                0,
                                ',',
                                '.'
                            ) }}
                            đ

                            @if ($service->price_unit)
                                / {{ $service->price_unit }}
                            @endif
                        </td>

                        <td>
                            <span class="badge">
                                {{ $service->status === 'ACTIVE'
                                    ? 'Đang hoạt động'
                                    : 'Tạm ngừng' }}
                            </span>
                        </td>

                        <td>
                            <div class="actions">
                                <a
                                    href="{{ route(
                                        'admin.services.show',
                                        $service
                                    ) }}"
                                    class="btn btn-secondary"
                                >
                                    Xem
                                </a>

                                <form
                                    method="POST"
                                    action="{{ route(
                                        'admin.services.status',
                                        $service
                                    ) }}"
                                >
                                    @csrf
                                    @method('PATCH')

                                    <input
                                        type="hidden"
                                        name="status"
                                        value="{{ $service->status === 'ACTIVE'
                                            ? 'INACTIVE'
                                            : 'ACTIVE' }}"
                                    >

                                    @if ($service->status === 'ACTIVE')
                                        <button
                                            type="submit"
                                            class="btn btn-warning"
                                            onclick="return confirm(
                                                'Tạm ngừng dịch vụ này?'
                                            );"
                                        >
                                            Tạm ngừng
                                        </button>
                                    @else
                                        <button
                                            type="submit"
                                            class="btn btn-primary"
                                        >
                                            Kích hoạt
                                        </button>
                                    @endif
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7">
                            Chưa có dịch vụ phù hợp.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        @if ($services->hasPages())
            <div class="pagination-wrapper">
                {{ $services->links() }}
            </div>
        @endif
    </div>
@endsection