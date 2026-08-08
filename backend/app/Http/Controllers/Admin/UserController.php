<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class UserController extends Controller
{
    public function index(Request $request): View
    {
        $validated = $request->validate([
            'search' => [
                'nullable',
                'string',
                'max:100',
            ],

            'role' => [
                'nullable',
                'in:CUSTOMER,PROVIDER,ADMIN',
            ],

            'status' => [
                'nullable',
                'in:ACTIVE,LOCKED',
            ],
        ]);

        $query = User::query()
            ->with('providerProfile')
            ->latest();

        if (! empty($validated['search'])) {
            $search = trim($validated['search']);

            $query->where(function ($query) use ($search) {
                $query
                    ->where(
                        'name',
                        'like',
                        "%{$search}%"
                    )
                    ->orWhere(
                        'email',
                        'like',
                        "%{$search}%"
                    )
                    ->orWhere(
                        'phone',
                        'like',
                        "%{$search}%"
                    );
            });
        }

        if (! empty($validated['role'])) {
            $query->where(
                'role',
                $validated['role']
            );
        }

        if (! empty($validated['status'])) {
            $query->where(
                'status',
                $validated['status']
            );
        }

        $users = $query
            ->paginate(10)
            ->withQueryString();

        return view(
            'admin.users.user_list',
            compact('users')
        );
    }

    public function show(User $user): View
    {
        $user->load([
            'providerProfile',
            'services',
            'customerBookings',
            'providerBookings',
        ]);

        return view(
            'admin.users.user_detail',
            compact('user')
        );
    }

    public function updateStatus(
        Request $request,
        User $user
    ): RedirectResponse {
        $validated = $request->validate([
            'status' => [
                'required',
                'in:ACTIVE,LOCKED',
            ],
        ]);

        /*
         * Không cho Admin thay đổi trạng thái
         * của bất kỳ tài khoản ADMIN nào.
         */
        if ($user->role === 'ADMIN') {
            return back()->with(
                'error',
                'Không thể thay đổi trạng thái tài khoản Admin.'
            );
        }

        /*
         * Bảo vệ bổ sung:
         * Admin hiện tại cũng không thể tự khóa chính mình.
         */
        if ($user->id === $request->user()->id) {
            return back()->with(
                'error',
                'Bạn không thể khóa tài khoản đang đăng nhập.'
            );
        }

        $user->status = $validated['status'];
        $user->save();

        /*
         * Khi khóa user, revoke toàn bộ Sanctum token.
         * Như vậy Flutter session hiện tại không tiếp tục
         * sử dụng API bằng token cũ.
         */
        if ($validated['status'] === 'LOCKED') {
            $user->tokens()->delete();
        }

        return back()->with(
            'success',
            $validated['status'] === 'LOCKED'
                ? 'Đã khóa tài khoản.'
                : 'Đã mở khóa tài khoản.'
        );
    }
}
