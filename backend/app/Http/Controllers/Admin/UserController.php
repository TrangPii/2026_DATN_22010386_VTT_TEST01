<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class UserController extends Controller
{
    // Danh sách người dùng
    public function index(
        Request $request
    ): View {
        $validated =
            $request->validate([
                'user_code' => [
                    'nullable',
                    'string',
                    'max:20',
                ],

                'name' => [
                    'nullable',
                    'string',
                    'max:100',
                ],

                'phone' => [
                    'nullable',
                    'string',
                    'max:30',
                ],

                'email' => [
                    'nullable',
                    'string',
                    'max:150',
                ],

                'role' => [
                    'nullable',
                    'in:CUSTOMER,ADMIN',
                ],

                'status' => [
                    'nullable',
                    'in:ACTIVE,LOCKED',
                ],

                'per_page' => [
                    'nullable',
                    'integer',
                    'in:6,12,24,48',
                ],
            ]);

        $query =
            User::query()
                ->orderByDesc(
                    'created_at'
                )
                ->orderByDesc(
                    'id'
                );

        if (
            ! empty(
                $validated['user_code']
            )
        ) {
            $userCode =
                trim(
                    $validated['user_code']
                );

            $query->where(
                'user_code',
                'like',
                "%{$userCode}%"
            );
        }

        if (
            ! empty(
                $validated['name']
            )
        ) {
            $name =
                trim(
                    $validated['name']
                );

            $query->where(
                'name',
                'like',
                "%{$name}%"
            );
        }

        if (
            ! empty(
                $validated['phone']
            )
        ) {
            $phone =
                trim(
                    $validated['phone']
                );

            $query->where(
                'phone',
                'like',
                "%{$phone}%"
            );
        }

        if (
            ! empty(
                $validated['email']
            )
        ) {
            $email =
                trim(
                    $validated['email']
                );

            $query->where(
                'email',
                'like',
                "%{$email}%"
            );
        }

        if (
            ! empty(
                $validated['role']
            )
        ) {
            $query->where(
                'role',
                $validated['role']
            );
        }

        if (
            ! empty(
                $validated['status']
            )
        ) {
            $query->where(
                'status',
                $validated['status']
            );
        }

        $users =
            $query
                ->paginate(6)
                ->withQueryString();

        return view(
            'admin.users.user_list',
            compact('users')
        );
    }

    // Chi tiết người dùng
    public function show(
        User $user
    ): View {
        return view(
            'admin.users.user_detail',
            compact('user')
        );
    }

    // Khóa / mở khóa tài khoản
    public function updateStatus(
        Request $request,
        User $user
    ): RedirectResponse {
        $validated =
            $request->validate([
                'status' => [
                    'required',
                    'in:ACTIVE,LOCKED',
                ],
            ]);

        // Không cho phép khóa Admin
        if (
            $user->role === 'ADMIN'
        ) {
            return back()->with(
                'error',
                'Không thể thay đổi trạng thái tài khoản Admin.'
            );
        }

        if (
            (int) $user->id ===
            (int) $request
                ->user()
                ->id
        ) {
            return back()->with(
                'error',
                'Bạn không thể khóa tài khoản đang đăng nhập.'
            );
        }

        if (
            $user->status ===
            $validated['status']
        ) {
            return back()->with(
                'error',
                'Tài khoản đã ở trạng thái này.'
            );
        }

        $user->update([
            'status' =>
                $validated['status'],
        ]);

        // Khi khóa User: thu hồi toàn bộ Sanctum token
        if (
            $validated['status'] ===
            'LOCKED'
        ) {
            $user
                ->tokens()
                ->delete();
        }

        return back()->with(
            'success',
            $validated['status'] ===
                'LOCKED'
                ? 'Đã khóa tài khoản.'
                : 'Đã mở khóa tài khoản.'
        );
    }
}