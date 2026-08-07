<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminUserController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'role' => [
                'nullable',
                'in:CUSTOMER,PROVIDER,ADMIN',
            ],

            'status' => [
                'nullable',
                'in:ACTIVE,LOCKED',
            ],

            'search' => [
                'nullable',
                'string',
                'max:100',
            ],

            'per_page' => [
                'nullable',
                'integer',
                'min:1',
                'max:100',
            ],
        ]);

        $query = User::query()
            ->with('providerProfile')
            ->latest();

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

        if (! empty($validated['search'])) {
            $search = $validated['search'];

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

        $users = $query->paginate(
            $validated['per_page'] ?? 20
        );

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy danh sách người dùng thành công.',

            'data' => [
                'users' => UserResource::collection(
                    $users->items()
                ),

                'pagination' => [
                    'current_page' =>
                        $users->currentPage(),

                    'last_page' =>
                        $users->lastPage(),

                    'total' =>
                        $users->total(),
                ],
            ],
        ]);
    }

    public function show(User $user): JsonResponse
    {
        $user->load('providerProfile');

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy thông tin người dùng thành công.',

            'data' => [
                'user' => new UserResource($user),
            ],
        ]);
    }

    public function updateStatus(
        Request $request,
        User $user
    ): JsonResponse {
        $validated = $request->validate([
            'status' => [
                'required',
                'in:ACTIVE,LOCKED',
            ],
        ]);

        if ($user->role === 'ADMIN') {
            return response()->json([
                'success' => false,
                'message' =>
                    'Không thể thay đổi trạng thái tài khoản quản trị.',
            ], 422);
        }

        $user->update([
            'status' => $validated['status'],
        ]);

        /*
         * Khi khóa user, vô hiệu hóa mọi Sanctum token.
         */
        if ($validated['status'] === 'LOCKED') {
            $user->tokens()->delete();
        }

        return response()->json([
            'success' => true,
            'message' =>
                'Cập nhật trạng thái tài khoản thành công.',

            'data' => [
                'user' => new UserResource($user),
            ],
        ]);
    }
}