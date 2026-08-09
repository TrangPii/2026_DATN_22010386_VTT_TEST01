<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class UserController extends Controller
{
    public function index(
        Request $request
    ): View {
        $validated = $request->validate([
            'search' => [
                'nullable',
                'string',
                'max:100',
            ],

            'role' => [
                'nullable',
                'in:CUSTOMER,ADMIN',
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
            $search = trim(
                $validated['search']
            );

            $query->where(
                function ($query) use ($search): void {
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
                }
            );
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

    public function show(
        User $user
    ): View {
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

        if ($user->role === 'ADMIN') {
            return back()->with(
                'error',
                'Không thể thay đổi trạng thái tài khoản Admin.'
            );
        }

        if (
            (int) $user->id ===
            (int) $request->user()->id
        ) {
            return back()->with(
                'error',
                'Bạn không thể khóa tài khoản đang đăng nhập.'
            );
        }

        $user->update([
            'status' => $validated['status'],
        ]);

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