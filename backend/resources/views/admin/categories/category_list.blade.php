@extends('admin.layouts.app')

@section('title', 'Quản lý danh mục')

@section('content')
    <div
        class="actions"
        style="justify-content: space-between; margin-bottom: 24px;"
    >
        <h1
            class="page-title"
            style="margin-bottom: 0;"
        >
            Quản lý danh mục
        </h1>

        <a
            href="{{ route('admin.categories.create') }}"
            class="btn btn-primary"
        >
            Thêm danh mục
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

    <form
        method="GET"
        action="{{ route('admin.categories.index') }}"
        class="filter-bar"
    >
        <input
            type="text"
            name="search"
            value="{{ request('search') }}"
            placeholder="Tên hoặc mô tả danh mục..."
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

        <button
            type="submit"
            class="btn btn-primary"
        >
            Lọc
        </button>

        <a
            href="{{ route('admin.categories.index') }}"
            class="btn btn-secondary"
        >
            Đặt lại
        </a>
    </form>

    <div class="card">
        <div class="card-header">
            Danh sách danh mục dịch vụ
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Tên</th>
                    <th>Slug</th>
                    <th>Thứ tự</th>
                    <th>Dịch vụ</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
            </thead>

            <tbody>
                @forelse ($categories as $category)
                    <tr>
                        <td>
                            #{{ $category->id }}
                        </td>

                        <td>
                            <strong>
                                {{ $category->name }}
                            </strong>
                        </td>

                        <td>
                            {{ $category->slug }}
                        </td>

                        <td>
                            {{ $category->display_order }}
                        </td>

                        <td>
                            {{ $category->services_count }}
                        </td>

                        <td>
                            <span class="badge">
                                {{ $category->status === 'ACTIVE'
                                    ? 'Đang hoạt động'
                                    : 'Tạm ngừng' }}
                            </span>
                        </td>

                        <td>
                            <div class="actions">
                                <a
                                    href="{{ route(
                                        'admin.categories.edit',
                                        $category
                                    ) }}"
                                    class="btn btn-secondary"
                                >
                                    Sửa
                                </a>

                                <form
                                    method="POST"
                                    action="{{ route(
                                        'admin.categories.status',
                                        $category
                                    ) }}"
                                >
                                    @csrf
                                    @method('PATCH')

                                    <input
                                        type="hidden"
                                        name="status"
                                        value="{{ $category->status === 'ACTIVE'
                                            ? 'INACTIVE'
                                            : 'ACTIVE' }}"
                                    >

                                    @if ($category->status === 'ACTIVE')
                                        <button
                                            type="submit"
                                            class="btn btn-warning"
                                            onclick="return confirm(
                                                'Tạm ngừng danh mục này?'
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
                            Chưa có danh mục phù hợp.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        @if ($categories->hasPages())
            <div class="pagination-wrapper">
                {{ $categories->links() }}
            </div>
        @endif
    </div>
@endsection