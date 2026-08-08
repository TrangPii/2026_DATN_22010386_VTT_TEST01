@extends('admin.layouts.app')

@section('title', 'Người dùng')
@section('header', 'Quản lý người dùng')

@section('content')

<h1 class="page-title">
    Người dùng
</h1>

@if(session('success'))
    <div class="alert alert-success">
        {{ session('success') }}
    </div>
@endif

@if(session('error'))
    <div class="alert alert-error">
        {{ session('error') }}
    </div>
@endif

<form
    method="GET"
    action="{{ route('admin.users.index') }}"
    class="filter-bar"
>

    <input
        class="form-control filter-search"
        type="text"
        name="search"
        value="{{ request('search') }}"
        placeholder="Tìm theo tên, email, số điện thoại..."
    >

    <select
        class="form-control"
        name="role"
    >
        <option value="">
            Tất cả vai trò
        </option>

        <option
            value="CUSTOMER"
            @selected(request('role') === 'CUSTOMER')
        >
            Customer
        </option>

        <option
            value="PROVIDER"
            @selected(request('role') === 'PROVIDER')
        >
            Provider
        </option>

        <option
            value="ADMIN"
            @selected(request('role') === 'ADMIN')
        >
            Admin
        </option>
    </select>

    <select
        class="form-control"
        name="status"
    >
        <option value="">
            Tất cả trạng thái
        </option>

        <option
            value="ACTIVE"
            @selected(request('status') === 'ACTIVE')
        >
            Active
        </option>

        <option
            value="LOCKED"
            @selected(request('status') === 'LOCKED')
        >
            Locked
        </option>
    </select>

    <button
        type="submit"
        class="btn btn-primary"
    >
        Lọc
    </button>

    <a
        href="{{ route('admin.users.index') }}"
        class="btn btn-secondary"
    >
        Xóa lọc
    </a>

</form>

<div class="card">

    <div class="card-header">
        Danh sách người dùng
        ({{ $users->total() }})
    </div>

    <div style="overflow-x:auto;">

        <table>

            <thead>
            <tr>
                <th>ID</th>
                <th>Người dùng</th>
                <th>Điện thoại</th>
                <th>Vai trò</th>
                <th>Trạng thái</th>
                <th>Đăng nhập cuối</th>
                <th>Thao tác</th>
            </tr>
            </thead>

            <tbody>

            @forelse($users as $user)

                <tr>

                    <td>
                        #{{ $user->id }}
                    </td>

                    <td>
                        <strong>
                            {{ $user->name }}
                        </strong>

                        <div style="
                            color:#6b7280;
                            font-size:13px;
                            margin-top:4px;
                        ">
                            {{ $user->email }}
                        </div>
                    </td>

                    <td>
                        {{ $user->phone ?? '-' }}
                    </td>

                    <td>
                        <span class="badge">
                            {{ $user->role }}
                        </span>
                    </td>

                    <td>
                        <span class="badge">
                            {{ $user->status }}
                        </span>
                    </td>

                    <td>
                        {{ $user->last_login_at
                            ? $user->last_login_at->format('d/m/Y H:i')
                            : 'Chưa đăng nhập'
                        }}
                    </td>

                    <td>

                        <div class="actions">

                            <a
                                href="{{ route(
                                    'admin.users.show',
                                    $user
                                ) }}"
                                class="btn btn-secondary"
                            >
                                Xem
                            </a>

                            @if($user->role !== 'ADMIN')

                                <form
                                    method="POST"
                                    action="{{ route(
                                        'admin.users.status',
                                        $user
                                    ) }}"
                                >
                                    @csrf
                                    @method('PATCH')

                                    <input
                                        type="hidden"
                                        name="status"
                                        value="{{ $user->status === 'ACTIVE'
                                            ? 'LOCKED'
                                            : 'ACTIVE'
                                        }}"
                                    >

                                    <button
                                        type="submit"
                                        class="btn {{ $user->status === 'ACTIVE'
                                            ? 'btn-warning'
                                            : 'btn-primary'
                                        }}"
                                    >
                                        {{ $user->status === 'ACTIVE'
                                            ? 'Khóa'
                                            : 'Mở khóa'
                                        }}
                                    </button>

                                </form>

                            @endif

                        </div>

                    </td>

                </tr>

            @empty

                <tr>
                    <td colspan="7">
                        Không tìm thấy người dùng.
                    </td>
                </tr>

            @endforelse

            </tbody>

        </table>

    </div>

    <div class="pagination-wrapper">
        {{ $users->links() }}
    </div>

</div>

@endsection