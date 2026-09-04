<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(
        Request $request
    ): JsonResponse {
        $validated =
            $request->validate([
                'per_page' => [
                    'nullable',
                    'integer',
                    'min:1',
                    'max:50',
                ],

                'audience' => [
                    'nullable',
                    'in:CUSTOMER,PROVIDER',
                ],
            ]);

        $query =
            $request
                ->user()
                ->notifications()
                ->latest();

        if (
            ! empty(
                $validated['audience']
            )
        ) {
            $query->where(
                'data->audience',
                $validated['audience']
            );
        }

        $notifications =
            $query->paginate(
                $validated['per_page']
                ?? 20
            );

        $items =
            collect(
                $notifications->items()
            )
                ->map(
                    fn ($notification) => [
                        'id' =>
                            $notification->id,

                        'type' =>
                            $notification
                                ->data['type']
                            ?? null,

                        'title' =>
                            $notification
                                ->data['title']
                            ?? '',

                        'message' =>
                            $notification
                                ->data['message']
                            ?? '',

                        'audience' =>
                            $notification
                                ->data['audience']
                            ?? null,

                        'target' =>
                            $notification
                                ->data['target']
                            ?? null,

                        'booking_id' =>
                            $notification
                                ->data['booking_id']
                            ?? null,

                        'booking_code' =>
                            $notification
                                ->data['booking_code']
                            ?? null,

                        'status' =>
                            $notification
                                ->data['status']
                            ?? null,

                        'read_at' =>
                            $notification
                                ->read_at
                                ?->toISOString(),

                        'created_at' =>
                            $notification
                                ->created_at
                                ?->toISOString(),
                    ]
                )
                ->values();

        return response()->json([
            'success' =>
                true,

            'message' =>
                'Lấy danh sách thông báo thành công.',

            'data' => [
                'notifications' =>
                    $items,

                'unread_count' =>
                    $request
                        ->user()
                        ->unreadNotifications()
                        ->count(),

                'pagination' => [
                    'current_page' =>
                        $notifications
                            ->currentPage(),

                    'last_page' =>
                        $notifications
                            ->lastPage(),

                    'per_page' =>
                        $notifications
                            ->perPage(),

                    'total' =>
                        $notifications
                            ->total(),
                ],
            ],
        ]);
    }

    public function unreadCount(
        Request $request
    ): JsonResponse {
        $validated =
            $request->validate([
                'audience' => [
                    'nullable',
                    'in:CUSTOMER,PROVIDER',
                ],
            ]);

        $query =
            $request
                ->user()
                ->unreadNotifications();

        if (
            ! empty(
                $validated['audience']
            )
        ) {
            $query->where(
                'data->audience',
                $validated['audience']
            );
        }

        return response()->json([
            'success' => true,

            'data' => [
                'unread_count' =>
                    $query->count(),
            ],
        ]);
    }

    public function markAsRead(
        Request $request,
        string $notification
    ): JsonResponse {
        $item =
            $request
                ->user()
                ->notifications()
                ->whereKey(
                    $notification
                )
                ->firstOrFail();

        $item->markAsRead();

        return response()->json([
            'success' =>
                true,

            'message' =>
                'Đã đánh dấu thông báo là đã đọc.',
        ]);
    }

    public function markAllAsRead(
        Request $request
    ): JsonResponse {
        $validated =
            $request->validate([
                'audience' => [
                    'required',
                    'in:CUSTOMER,PROVIDER',
                ],
            ]);

        $request
            ->user()
            ->unreadNotifications()
            ->where(
                'data->audience',
                $validated['audience']
            )
            ->update([
                'read_at' =>
                    now(),
            ]);

        return response()->json([
            'success' => true,

            'message' =>
                'Đã đọc tất cả thông báo.',
        ]);
    }
}