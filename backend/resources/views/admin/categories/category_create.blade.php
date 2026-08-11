@extends('admin.layouts.app')

@section('title', 'Thêm danh mục')

@section('header')
    Quản lý danh mục dịch vụ

    <p class="admin-page-subtitle">
        Tạo danh mục dịch vụ mới cho hệ thống.
    </p>
@endsection

@section('content')

<div class="admin-page-heading">

    <div>
        <h1 class="admin-page-title">
            Thêm danh mục
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
        action="{{ route('admin.categories.store') }}"
        class="admin-form-body"
    >
        @csrf

        <div class="admin-form-grid">

            <div class="form-group">
                <label for="name">
                    Tên danh mục
                </label>

                <input
                    id="name"
                    type="text"
                    name="name"
                    value="{{ old('name') }}"
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
                    value="{{ old('image') }}"
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
                    placeholder="Nhập mô tả danh mục"
                >{{ old('description') }}</textarea>

                @error('description')
                    <div class="error">
                        {{ $message }}
                    </div>
                @enderror

            </div>

        </div>

        <div class="admin-form-actions">

            <button
                type="submit"
                class="btn btn-primary"
            >
                Tạo danh mục
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