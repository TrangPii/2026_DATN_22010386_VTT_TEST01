@extends('admin.layouts.app')

@section('title', 'Quản lý danh mục dịch vụ')

@section('header')
    Quản lý danh mục dịch vụ

    <p class="admin-page-subtitle">
        Quản lý danh mục và trạng thái hiển thị dịch vụ trên hệ thống.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">

    <div>
        <h1 class="admin-page-title">
            Danh sách danh mục
        </h1>
    </div>

    <a
        href="{{ route('admin.categories.create') }}"
        class="btn btn-primary"
    >
        + Thêm danh mục
    </a>

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
        action="{{ route('admin.categories.index') }}"
        class="admin-filter-form"
    >

        <div class="admin-filter-grid">

            <div class="admin-filter-field">
                <label for="search">
                    Tên danh mục
                </label>

                <input
                    id="search"
                    type="text"
                    name="search"
                    value="{{ request('search') }}"
                    class="form-control"
                    placeholder="Nhập tên hoặc mô tả danh mục"
                    maxlength="100"
                    autocomplete="off"
                >
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
                        Tạm ngừng
                    </option>
                </select>
            </div>

            <div class="admin-filter-field">
                <label for="sort">
                    Sắp xếp
                </label>

                <select
                    id="sort"
                    name="sort"
                    class="form-control"
                >
                    <option
                        value="newest"
                        @selected(
                            request('sort', 'newest') === 'newest'
                        )
                    >
                        Mới nhất
                    </option>

                    <option
                        value="services_desc"
                        @selected(
                            request('sort') === 'services_desc'
                        )
                    >
                        Số dịch vụ giảm dần
                    </option>

                    <option
                        value="services_asc"
                        @selected(
                            request('sort') === 'services_asc'
                        )
                    >
                        Số dịch vụ tăng dần
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
                href="{{ route('admin.categories.index') }}"
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
                {{ $categories->total() }} bản ghi
            </span>

        </div>

    </div>

    <div class="admin-table-scroll">

        <table class="admin-data-table">

            <thead>
                <tr>
                    <th>STT</th>
                    <th>Tên danh mục</th>
                    <th>Mô tả</th>
                    <th>Số dịch vụ</th>
                    <th>Ngày tạo</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>

            <tbody>

                @forelse ($categories as $category)

                    <tr>

                        <td class="table-index">
                            {{ $categories->firstItem() + $loop->index }}
                        </td>

                        <td class="table-name">
                            <strong>
                                {{ $category->name }}
                            </strong>
                        </td>

                        <td class="table-description">
                            {{ $category->description ?: '—' }}
                        </td>

                        <td>
                            {{ $category->services_count }}
                        </td>

                        <td class="table-date">

                            @if ($category->created_at)

                                <span class="date-value">
                                    {{ $category->created_at->format('d/m/Y') }}
                                </span>

                                <span class="time-value">
                                    {{ $category->created_at->format('H:i:s') }}
                                </span>

                            @else
                                —
                            @endif

                        </td>

                        <td class="table-status">

                            @if ($category->status === 'ACTIVE')

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
                                        'admin.categories.edit',
                                        $category
                                    ) }}"
                                    class="icon-action-button"
                                    title="Chỉnh sửa danh mục"
                                    aria-label="Chỉnh sửa {{ $category->name }}"
                                >
                                    ✎
                                </a>

                                @if ($category->status === 'ACTIVE')

                                    <form
                                        method="POST"
                                        action="{{ route(
                                            'admin.categories.status',
                                            $category
                                        ) }}"
                                        onsubmit="return confirm(
                                            'Bạn có chắc muốn vô hiệu danh mục này?'
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
                                            title="Vô hiệu danh mục"
                                            aria-label="Vô hiệu {{ $category->name }}"
                                        >
                                            🔒
                                        </button>
                                    </form>

                                @else

                                    <form
                                        method="POST"
                                        action="{{ route(
                                            'admin.categories.status',
                                            $category
                                        ) }}"
                                        onsubmit="return confirm(
                                            'Bạn có chắc muốn kích hoạt lại danh mục này?'
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
                                            title="Kích hoạt danh mục"
                                            aria-label="Kích hoạt {{ $category->name }}"
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
                            colspan="7"
                            class="admin-empty-state"
                        >
                            Không tìm thấy danh mục phù hợp.
                        </td>
                    </tr>

                @endforelse

            </tbody>

        </table>

    </div>

    @if ($categories->hasPages())
        <div class="admin-pagination">
            {{ $categories->onEachSide(1)->links() }}
        </div>
    @endif

</div>

@endsection