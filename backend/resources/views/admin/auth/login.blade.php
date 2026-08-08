<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>
        Admin Login - Smart Service Hub
    </title>

    <link
        rel="stylesheet"
        href="{{ asset('css/admin.css') }}"
    >
</head>

<body>

<div class="login-page">

    <div class="login-card">

        <h1 style="margin-top:0;">
            Smart Service Hub
        </h1>

        <p style="color:#6b7280;">
            Đăng nhập hệ thống quản trị
        </p>

        <form
            method="POST"
            action="{{ route('admin.login.submit') }}"
        >

            @csrf

            <div class="form-group">

                <label for="email">
                    Email
                </label>

                <input
                    class="form-control"
                    id="email"
                    type="email"
                    name="email"
                    value="{{ old('email') }}"
                    required
                    autofocus
                >

                @error('email')
                    <div class="error">
                        {{ $message }}
                    </div>
                @enderror

            </div>

            <div class="form-group">

                <label for="password">
                    Mật khẩu
                </label>

                <input
                    class="form-control"
                    id="password"
                    type="password"
                    name="password"
                    required
                >

            </div>

            <div class="form-group">

                <label>
                    <input
                        type="checkbox"
                        name="remember"
                        value="1"
                    >

                    Ghi nhớ đăng nhập
                </label>

            </div>

            <button
                class="btn"
                style="
                    width:100%;
                    background:#111827;
                    color:#fff;
                "
                type="submit"
            >
                Đăng nhập
            </button>

        </form>

    </div>

</div>

</body>
</html>