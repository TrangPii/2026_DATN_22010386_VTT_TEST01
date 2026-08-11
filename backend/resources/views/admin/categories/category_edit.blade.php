@extends('admin.layouts.app')

@section('title', 'Chỉnh sửa danh mục')

@section('header')
    Quản lý danh mục dịch vụ

    <p class="admin-page-subtitle">
        Cập nhật thông tin danh mục dịch vụ.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">

    <div>
        <h1 class="admin-page-title">
            Chỉnh sửa danh mục
        </h1>
    </div>

    <a
        href="{{ route('admin.categories.index') }}"
        class="btn btn-secondary"
    >
        ← Quay lại
    </a>

</div>


@if ($errors->any())

    <div class="alert alert-error">

        <strong>
            Vui lòng kiểm tra lại thông tin.
        </strong>

        <ul class="form-error-list">
            @foreach ($errors->all() as $error)
                <li>
                    {{ $error }}
                </li>
            @endforeach
        </ul>

    </div>

@endif


<div class="admin-section-card">

    <div class="admin-detail-header">

        <h4 class="admin-section-title">
            Thông tin danh mục
        </h4>

    </div>

    <form
        method="POST"
        action="{{ route(
            'admin.categories.update',
            $category
        ) }}"
        class="admin-form-body"
    >
        @csrf
        @method('PUT')

        <div class="admin-form-grid">

            <div class="form-group">

                <label for="name">
                    Tên danh mục
                </label>

                <input
                    id="name"
                    type="text"
                    name="name"
                    value="{{ old(
                        'name',
                        $category->name
                    ) }}"
                    class="form-control"
                    maxlength="255"
                    autocomplete="off"
                    required
                >

                @error('name')
                    <div class="error">
                        {{ $message }}
                    </div>
                @enderror

            </div>


            <div class="form-group">

                <label for="image">
                    Ảnh / URL ảnh
                </label>

                <input
                    id="image"
                    type="text"
                    name="image"
                    value="{{ old(
                        'image',
                        $category->image
                    ) }}"
                    class="form-control"
                    maxlength="255"
                    autocomplete="off"
                >

                @error('image')
                    <div class="error">
                        {{ $message }}
                    </div>
                @enderror

            </div>


            <div class="form-group admin-form-field-wide">

                <label for="description">
                    Mô tả
                </label>

                <textarea
                    id="description"
                    name="description"
                    class="form-control form-control-textarea"
                    maxlength="2000"
                >{{ old(
                    'description',
                    $category->description
                ) }}</textarea>

                @error('description')
                    <div class="error">
                        {{ $message }}
                    </div>
                @enderror

            </div>


            <div class="form-group">

                <label>
                    Trạng thái hiện tại
                </label>

                <div class="form-readonly-value">

                    @if ($category->status === 'ACTIVE')

                        <span class="status-badge status-badge-success">
                            Hoạt động
                        </span>

                    @else

                        <span class="status-badge status-badge-warning">
                            Tạm ngừng
                        </span>

                    @endif

                </div>

            </div>


            <div class="form-group">

                <label>
                    Slug
                </label>

                <div class="form-readonly-value">
                    {{ $category->slug }}
                </div>

            </div>

        </div>


        <div class="admin-form-actions">

            <button
                type="submit"
                class="btn btn-primary"
            >
                Lưu thay đổi
            </button>

            <a
                href="{{ route('admin.categories.index') }}"
                class="btn btn-secondary"
            >
                Hủy
            </a>

        </div>

    </form>

</div>

@endsection