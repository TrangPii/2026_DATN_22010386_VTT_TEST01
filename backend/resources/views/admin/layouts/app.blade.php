<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>
        @yield('title', 'Admin')
        - Smart Service Hub
    </title>

    <link
        rel="stylesheet"
        href="{{ asset('css/admin.css') }}"
    >
</head>

<body>

<div class="admin-shell">

    <aside class="admin-sidebar">

        <div class="admin-brand">
            Smart Service Hub
        </div>

        <nav class="admin-nav">

            <a
                href="{{ route('admin.dashboard') }}"
                class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}"
            >
                Dashboard
            </a>

            <a
                href="{{ route('admin.users.index') }}"
                class="{{ request()->routeIs('admin.users.*') ? 'active' : '' }}"
            >
                Người dùng
            </a>

            <a
                href="{{ route('admin.providers.index') }}"
                class="{{ request()->routeIs('admin.providers.*')? 'active': '' }}"
            >
            Nhà cung cấp
            </a>

            <a href="#">
                Danh mục
            </a>

            <a href="#">
                Dịch vụ
            </a>

            <a href="#">
                Booking
            </a>

        </nav>

    </aside>

    <main class="admin-main">

        <header class="admin-header">

            <div>
                @yield('header', 'Quản trị hệ thống')
            </div>

            <div style="
                display:flex;
                align-items:center;
                gap:16px;
            ">

                <span>
                    {{ auth()->user()->name }}
                </span>

                <form
                    method="POST"
                    action="{{ route('admin.logout') }}"
                >
                    @csrf

                    <button
                        class="btn btn-danger"
                        type="submit"
                    >
                        Đăng xuất
                    </button>
                </form>

            </div>

        </header>

        <section class="admin-content">
            @yield('content')
        </section>

    </main>

</div>

</body>
</html>