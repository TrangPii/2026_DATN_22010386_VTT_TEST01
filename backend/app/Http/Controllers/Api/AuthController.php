<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Throwable;

class AuthController extends Controller
{
    /**
     * Đăng ký tài khoản người dùng.
     *
     * Mọi tài khoản đăng ký từ Mobile App đều bắt đầu
     * với quyền CUSTOMER.
     *
     * Quyền Provider được cấp bổ sung sau khi:
     * - user gửi provider application;
     * - Admin approve provider profile.
     */
    public function register(
        RegisterRequest $request
    ): JsonResponse {
        $validated = $request->validated();

        try {
            $result = DB::transaction(
                function () use ($validated): array {
                    $user = User::create([
                        'name' => $validated['name'],
                        'email' => $validated['email'],
                        'phone' => $validated['phone'],
                        'password' => $validated['password'],
                        'role' => 'CUSTOMER',
                        'status' => 'ACTIVE',
                    ]);

                    /*
                     * Token không còn quyết định user có phải
                     * Provider hay không.
                     *
                     * Provider authorization sẽ được kiểm tra
                     * bởi provider.approved middleware.
                     */
                    $token = $user
                        ->createToken(
                            $validated['device_name']
                                ?? 'mobile-app',
                            ['mobile']
                        )
                        ->plainTextToken;

                    return [
                        'user' => $user,
                        'token' => $token,
                    ];
                }
            );

            $result['user']->loadMissing(
                'providerProfile'
            );

            return response()->json([
                'success' => true,
                'message' =>
                    'Đăng ký tài khoản thành công.',

                'data' => [
                    'user' => new UserResource(
                        $result['user']
                    ),

                    'token' => $result['token'],

                    'token_type' => 'Bearer',
                ],
            ], 201);
        } catch (Throwable $exception) {
            report($exception);

            return response()->json([
                'success' => false,
                'message' =>
                    'Không thể đăng ký tài khoản.',
            ], 500);
        }
    }

    /**
     * Đăng nhập và phát hành token Sanctum.
     */
    public function login(
        LoginRequest $request
    ): JsonResponse {
        $validated = $request->validated();

        $user = User::query()
            ->where(
                'email',
                $validated['email']
            )
            ->first();

        if (
            $user === null ||
            ! Hash::check(
                $validated['password'],
                $user->password
            )
        ) {
            throw ValidationException::withMessages([
                'email' => [
                    'Email hoặc mật khẩu không chính xác.',
                ],
            ]);
        }

        if ($user->status !== 'ACTIVE') {
            return response()->json([
                'success' => false,

                'message' =>
                    'Tài khoản đang bị khóa.',

                'errors' => [
                    'account' => [
                        'Vui lòng liên hệ quản trị viên để được hỗ trợ.',
                    ],
                ],
            ], 403);
        }

        $user->forceFill([
            'last_login_at' => now(),
        ])->save();

        $user->loadMissing(
            'providerProfile'
        );

        $abilities = $user->role === 'ADMIN'
            ? ['admin']
            : ['mobile'];

        $token = $user
            ->createToken(
                $validated['device_name']
                    ?? 'mobile-app',
                $abilities
            )
            ->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Đăng nhập thành công.',

            'data' => [
                'user' => new UserResource($user),

                'token' => $token,

                'token_type' => 'Bearer',
            ],
        ]);
    }

    /**
     * Lấy tài khoản đang đăng nhập.
     */
    public function me(
        Request $request
    ): JsonResponse {
        $user = $request->user();

        $user->loadMissing(
            'providerProfile'
        );

        return response()->json([
            'success' => true,

            'message' =>
                'Lấy thông tin tài khoản thành công.',

            'data' => [
                'user' => new UserResource($user),
            ],
        ]);
    }

    /**
     * Đăng xuất thiết bị hiện tại.
     */
    public function logout(
        Request $request
    ): JsonResponse {
        $currentToken = $request
            ->user()
            ->currentAccessToken();

        if ($currentToken !== null) {
            $currentToken->delete();
        }

        return response()->json([
            'success' => true,
            'message' => 'Đăng xuất thành công.',
            'data' => null,
        ]);
    }

    /**
     * Đăng xuất khỏi tất cả thiết bị.
     */
    public function logoutAll(
        Request $request
    ): JsonResponse {
        $request
            ->user()
            ->tokens()
            ->delete();

        return response()->json([
            'success' => true,

            'message' =>
                'Đã đăng xuất khỏi tất cả thiết bị.',

            'data' => null,
        ]);
    }
}