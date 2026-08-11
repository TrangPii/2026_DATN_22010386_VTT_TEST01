@extends('admin.layouts.app')

@section('title', 'Quản lý dịch vụ')

@section('header')
    Quản lý dịch vụ

    <p class="admin-page-subtitle">
        Quản lý dịch vụ được cung cấp trên hệ thống.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">

    <div>
        <h1 class="admin-page-title">
            Danh sách dịch vụ
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
        action="{{ route('admin.services.index') }}"
        class="admin-filter-form"
    >

        <div class="admin-filter-grid">

            <div class="admin-filter-field">

                <label for="search">
                    Tên dịch vụ
                </label>

                <input
                    id="search"
                    type="text"
                    name="search"
                    value="{{ request('search') }}"
                    class="form-control"
                    placeholder="Nhập từ khóa tìm kiếm"
                    maxlength="100"
                    autocomplete="off"
                >

            </div>


            <div class="admin-filter-field">

                <label for="category_search">
                    Danh mục
                </label>

                <input
                    id="category_search"
                    type="text"
                    class="form-control filter-combobox-input"
                    list="category_options"
                    placeholder="Chọn hoặc nhập danh mục"
                    autocomplete="off"
                    value="{{
                        optional(
                            $categories->firstWhere(
                                'id',
                                (int) request('category_id')
                            )
                        )->name
                    }}"
                    data-combobox="category"
                >

                <input
                    id="category_id"
                    type="hidden"
                    name="category_id"
                    value="{{ request('category_id') }}"
                >

                <datalist id="category_options">
                    @foreach ($categories as $category)
                        <option
                            value="{{ $category->name }}"
                            data-id="{{ $category->id }}"
                        ></option>
                    @endforeach
                </datalist>

            </div>

            <div class="admin-filter-field">

                <label for="provider_search">
                    Nhà cung cấp
                </label>

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
                        ?? optional(
                            $providers->firstWhere(
                                'id',
                                (int) request('provider_id')
                            )
                        )->name
                    }}"
                    data-combobox="provider"
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
                            value="{{
                                $provider->providerProfile?->business_name
                                ?? $provider->name
                            }}"
                            data-id="{{ $provider->id }}"
                        ></option>

                    @endforeach

                </datalist>

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
                        @selected(
                            request('status') === 'ACTIVE'
                        )
                    >
                        Hoạt động
                    </option>

                    <option
                        value="INACTIVE"
                        @selected(
                            request('status') === 'INACTIVE'
                        )
                    >
                        Vô hiệu
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
                href="{{ route('admin.services.index') }}"
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
                {{ $services->total() }} bản ghi
            </span>

        </div>

    </div>


    <div class="admin-table-scroll">

        <table class="admin-data-table">

            <thead>

                <tr>
                    <th>STT</th>
                    <th>Dịch vụ</th>
                    <th>Mô tả</th>
                    <th>Danh mục</th>
                    <th>Nhà cung cấp</th>
                    <th>Giá</th>
                    <th>Ngày tạo</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>

            </thead>


            <tbody>

                @forelse ($services as $service)

                    <tr>

                        <td class="table-index">
                            {{ $services->firstItem() + $loop->index }}
                        </td>


                        <td class="table-name">

                            <strong>
                                {{ $service->name }}
                            </strong>

                        </td>


                        <td class="table-description">
                            {{ $service->description ?: '—' }}
                        </td>


                        <td class="table-name">
                            {{ $service->category?->name ?? '—' }}
                        </td>


                        <td class="table-provider">

                            @if ($service->provider?->providerProfile)

                                <a
                                    href="{{ route(
                                        'admin.providers.show',
                                        $service->provider->providerProfile
                                    ) }}"
                                    class="table-link"
                                >
                                    {{
                                        $service
                                            ->provider
                                            ->providerProfile
                                            ->business_name
                                    }}
                                </a>

                            @else

                                {{ $service->provider?->name ?? '—' }}

                            @endif

                        </td>


                        <td class="table-price">

                            <strong>
                                {{ number_format(
                                    (float) $service->price,
                                    0,
                                    ',',
                                    '.'
                                ) }}
                                đ
                            </strong>

                            @if ($service->price_unit)

                                <span class="table-muted">
                                    / {{ $service->price_unit }}
                                </span>

                            @endif

                        </td>


                        <td class="table-date">

                            @if ($service->created_at)

                                <span class="date-value">
                                    {{ $service->created_at->format('d/m/Y') }}
                                </span>

                                <span class="time-value">
                                    {{ $service->created_at->format('H:i:s') }}
                                </span>

                            @else
                                —
                            @endif

                        </td>


                        <td class="table-status">

                            @if ($service->status === 'ACTIVE')

                                <span class="status-badge status-badge-success">
                                    Hoạt động
                                </span>

                            @else

                                <span class="status-badge status-badge-danger">
                                    Vô hiệu
                                </span>

                            @endif

                        </td>


                        <td class="table-action">

                            <div class="table-actions">

                                <a
                                    href="{{ route(
                                        'admin.services.show',
                                        $service
                                    ) }}"
                                    class="icon-action-button"
                                    title="Xem chi tiết"
                                    aria-label="Xem chi tiết {{ $service->name }}"
                                >
                                    i
                                </a>


                                @if ($service->status === 'ACTIVE')

                                    <form
                                        method="POST"
                                        action="{{ route(
                                            'admin.services.status',
                                            $service
                                        ) }}"
                                        onsubmit="return confirm(
                                            'Bạn có chắc muốn vô hiệu dịch vụ này?'
                                        );"
                                    >
                                        @csrf
                                        @method('PATCH')

                                        <input
                                            type="hidden"
                                            name="status"
                                            value="INACTIVE"
                                        >

                                        <button
                                            type="submit"
                                            class="icon-action-button icon-action-danger"
                                            title="Vô hiệu dịch vụ"
                                            aria-label="Vô hiệu {{ $service->name }}"
                                        >
                                            🔒
                                        </button>

                                    </form>

                                @else

                                    <form
                                        method="POST"
                                        action="{{ route(
                                            'admin.services.status',
                                            $service
                                        ) }}"
                                        onsubmit="return confirm(
                                            'Bạn có chắc muốn kích hoạt dịch vụ này?'
                                        );"
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
                                            title="Kích hoạt dịch vụ"
                                            aria-label="Kích hoạt {{ $service->name }}"
                                        >
                                            🔓
                                        </button>

                                    </form>

                                @endif

                            </div>

                        </td>

                    </tr>

                @empty

                    <tr>

                        <td
                            colspan="9"
                            class="admin-empty-state"
                        >
                            Không tìm thấy dịch vụ phù hợp.
                        </td>

                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>


    @if ($services->hasPages())

        <div class="admin-pagination">
            {{ $services->onEachSide(1)->links() }}
        </div>

    @endif

</div>

<script>
document.addEventListener('DOMContentLoaded', function () {

    function initFilterCombobox(config) {
        const input =
            document.getElementById(config.inputId);

        const hidden =
            document.getElementById(config.hiddenId);

        const datalist =
            document.getElementById(config.datalistId);

        if (!input || !hidden || !datalist) {
            return;
        }

        const syncValue = function () {
            const value =
                input.value.trim();

            const options =
                Array.from(
                    datalist.options
                );

            const matchedOption =
                options.find(
                    option =>
                        option.value === value
                );

            hidden.value =
                matchedOption
                    ? matchedOption.dataset.id
                    : '';
        };

        input.addEventListener(
            'input',
            syncValue
        );

        input.addEventListener(
            'change',
            syncValue
        );
    }


    initFilterCombobox({
        inputId: 'category_search',
        hiddenId: 'category_id',
        datalistId: 'category_options'
    });


    initFilterCombobox({
        inputId: 'provider_search',
        hiddenId: 'provider_id',
        datalistId: 'provider_options'
    });

});
</script>
@endsection