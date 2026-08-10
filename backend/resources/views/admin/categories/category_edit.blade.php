@extends('admin.layouts.app')

@section('title', 'Chỉnh sửa danh mục')

@section('content')
    <div
        class="actions"
        style="justify-content: space-between; margin-bottom: 24px;"
    >
        <h1
            class="page-title"
            style="margin-bottom: 0;"
        >
            Chỉnh sửa danh mục
        </h1>

        <a
            href="{{ route('admin.categories.index') }}"
            class="btn btn-secondary"
        >
            Quay lại
        </a>
    </div>

    @if ($errors->any())
        <div class="alert alert-error">
            <strong>
                Vui lòng kiểm tra lại thông tin.
            </strong>

            <ul style="margin-bottom: 0;">
                @foreach ($errors->all() as $error)
                    <li>
                        {{ $error }}
                    </li>
                @endforeach
            </ul>
        </div>
    @endif

    <div class="card">
        <div class="card-header">
            Thông tin danh mục
        </div>

        <form
            method="POST"
            action="{{ route(
                'admin.categories.update',
                $category
            ) }}"
            style="padding: 20px;"
        >
            @csrf
            @method('PUT')

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
                    required
                >

                @error('name')
                    <div class="error">
                        {{ $message }}
                    </div>
                @enderror
            </div>

            <div class="form-group">
                <label for="description">
                    Mô tả
                </label>

                <textarea
                    id="description"
                    name="description"
                    class="form-control"
                    rows="5"
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
                >

                @error('image')
                    <div class="error">
                        {{ $message }}
                    </div>
                @enderror
            </div>

            <div class="form-group">
                <label for="display_order">
                    Thứ tự hiển thị
                </label>

                <input
                    id="display_order"
                    type="number"
                    name="display_order"
                    value="{{ old(
                        'display_order',
                        $category->display_order
                    ) }}"
                    class="form-control"
                    min="0"
                >

                @error('display_order')
                    <div class="error">
                        {{ $message }}
                    </div>
                @enderror
            </div>

            <div class="detail-item">
                <div class="detail-label">
                    Trạng thái hiện tại
                </div>

                <div class="detail-value">
                    {{ $category->status === 'ACTIVE'
                        ? 'Đang hoạt động'
                        : 'Tạm ngừng' }}
                </div>
            </div>

            <div
                class="actions"
                style="margin-top: 20px;"
            >
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