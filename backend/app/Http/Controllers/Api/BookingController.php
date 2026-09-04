<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Booking\CancelBookingRequest;
use App\Http\Requests\Booking\StoreBookingRequest;
use App\Http\Resources\BookingResource;
use App\Models\Booking;
use App\Models\BookingStatusHistory;
use App\Models\ProviderProfile;
use App\Models\Service;
use App\Notifications\SystemNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    public function index(
        Request $request
    ): JsonResponse {
        if (
            $request->user()->role !==
            'CUSTOMER'
        ) {
            abort(
                403,
                'Bạn không có quyền truy cập.'
            );
        }

        $validated =
            $request->validate([
                'status' => [
                    'nullable',
                    'string',
                    'in:PENDING,ACCEPTED,IN_PROGRESS,COMPLETED,REJECTED,CANCELLED',
                ],

                'per_page' => [
                    'nullable',
                    'integer',
                    'min:1',
                    'max:50',
                ],
            ]);

        $query =
            Booking::query()
                ->where(
                    'customer_id',
                    $request->user()->id
                )
                ->with([
                    'provider.providerProfile',
                    'service',
                ])
                ->latest();

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

        $bookings =
            $query->paginate(
                $validated[
                    'per_page'
                ] ?? 10
            );

        return response()->json([
            'success' => true,

            'message' =>
                'Lấy danh sách đơn thành công.',

            'data' => [
                'bookings' =>
                    BookingResource::
                        collection(
                            $bookings
                                ->items()
                        ),

                'pagination' => [
                    'current_page' =>
                        $bookings
                            ->currentPage(),

                    'last_page' =>
                        $bookings
                            ->lastPage(),

                    'per_page' =>
                        $bookings
                            ->perPage(),

                    'total' =>
                        $bookings
                            ->total(),
                ],
            ],
        ]);
    }

    public function store(
        StoreBookingRequest $request
    ): JsonResponse {
        $validated =
            $request->validated();

        $service =
            Service::query()
                ->with([
                    'provider.providerProfile',
                    'category',
                ])
                ->findOrFail(
                    $validated[
                        'service_id'
                    ]
                );

        $provider =
            $service->provider;

        $profile =
            $provider
                ?->providerProfile;

        /*
         * Kiểm tra toàn bộ điều kiện
         * khả dụng trong một block.
         */
        if (
            $service->status !==
                'ACTIVE'

            || $service->category ===
                null

            || $service
                ->category
                ->status !==
                'ACTIVE'

            || $provider === null

            || $provider->status !==
                'ACTIVE'

            || $profile === null

            || $profile
                ->verification_status !==
                ProviderProfile::
                    VERIFICATION_APPROVED

            || $profile
                ->provider_status !==
                ProviderProfile::
                    STATUS_ACTIVE
        ) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Dịch vụ hiện không khả dụng.',
            ], 422);
        }

        if (
            (int) $service->provider_id ===
            (int) $request->user()->id
        ) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Bạn không thể đặt dịch vụ của chính mình.',
            ], 422);
        }

        $quantity =
            $validated[
                'quantity'
            ] ?? 1;

        $unitPrice =
            $service->price;

        $totalAmount =
            bcmul(
                (string) $unitPrice,
                (string) $quantity,
                2
            );

        $booking =
            DB::transaction(
                function () use (
                    $request,
                    $validated,
                    $service,
                    $quantity,
                    $unitPrice,
                    $totalAmount
                ): Booking {
                    $booking =
                        Booking::create([
                            'booking_code' =>
                                $this
                                    ->generateBookingCode(),

                            'customer_id' =>
                                $request
                                    ->user()
                                    ->id,

                            'provider_id' =>
                                $service
                                    ->provider_id,

                            'service_id' =>
                                $service->id,

                            'service_name' =>
                                $service->name,

                            'unit_price' =>
                                $unitPrice,

                            'quantity' =>
                                $quantity,

                            'total_amount' =>
                                $totalAmount,

                            'booking_date' =>
                                $validated[
                                    'booking_date'
                                ],

                            'booking_time' =>
                                $validated[
                                    'booking_time'
                                ],

                            'customer_name' =>
                                $validated[
                                    'customer_name'
                                ],

                            'customer_phone' =>
                                $validated[
                                    'customer_phone'
                                ],

                            'service_address' =>
                                $validated[
                                    'service_address'
                                ],

                            'note' =>
                                $validated[
                                    'note'
                                ] ?? null,

                            'status' =>
                                'PENDING',
                        ]);

                    BookingStatusHistory::
                        create([
                            'booking_id' =>
                                $booking->id,

                            'changed_by' =>
                                $request
                                    ->user()
                                    ->id,

                            'old_status' =>
                                null,

                            'new_status' =>
                                'PENDING',

                            'note' =>
                                'Khách hàng tạo yêu cầu đặt dịch vụ.',
                        ]);

                    return $booking;
                }
            );

            $provider->notify(
                new SystemNotification(
                    type:
                        'BOOKING_CREATED',

                    title:
                        'Bạn có đơn hàng mới',

                    message:
                        'Khách hàng vừa đặt dịch vụ "'
                        . $booking->service_name
                        . '".',
                    audience:
                        'PROVIDER',

                    target:
                        'PROVIDER_BOOKING_DETAIL',

                    bookingId:
                        $booking->id,

                    bookingCode:
                        $booking->booking_code,

                    status:
                        $booking->status,
                )
            );

        $booking->load([
            'customer',
            'provider.providerProfile',
            'service',
            'statusHistories.changedByUser',
        ]);

        return response()->json([
            'success' => true,

            'message' =>
                'Đặt dịch vụ thành công.',

            'data' => [
                'booking' =>
                    new BookingResource(
                        $booking
                    ),
            ],
        ], 201);
    }

    public function show(
        Request $request,
        Booking $booking
    ): JsonResponse {
        if (
            $request
                ->user()
                ->role !==
                'CUSTOMER'

            || $booking
                ->customer_id !==
                $request
                    ->user()
                    ->id
        ) {
            abort(
                403,
                'Bạn không có quyền xem đơn này.'
            );
        }

        $booking->load([
            'customer',
            'provider.providerProfile',
            'service',
            'statusHistories.changedByUser',
            'review',
        ]);

        return response()->json([
            'success' => true,

            'message' =>
                'Lấy thông tin đơn thành công.',

            'data' => [
                'booking' =>
                    new BookingResource(
                        $booking
                    ),
            ],
        ]);
    }

    public function cancel(
        CancelBookingRequest $request,
        Booking $booking
    ): JsonResponse {
        if (
            $booking
                ->customer_id !==
            $request
                ->user()
                ->id
        ) {
            abort(
                403,
                'Bạn không có quyền hủy đơn này.'
            );
        }

        if (
            ! in_array(
                $booking->status,
                [
                    'PENDING',
                    'ACCEPTED',
                ],
                true
            )
        ) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Đơn ở trạng thái hiện tại không thể hủy.',
            ], 422);
        }

        $oldStatus =
            $booking->status;

        DB::transaction(
            function () use (
                $request,
                $booking,
                $oldStatus
            ): void {
                $booking->update([
                    'status' =>
                        'CANCELLED',

                    'cancellation_reason' =>
                        $request
                            ->validated(
                                'reason'
                            ),

                    'cancelled_at' =>
                        now(),
                ]);

                BookingStatusHistory::
                    create([
                        'booking_id' =>
                            $booking->id,

                        'changed_by' =>
                            $request
                                ->user()
                                ->id,

                        'old_status' =>
                            $oldStatus,

                        'new_status' =>
                            'CANCELLED',

                        'note' =>
                            $request
                                ->validated(
                                    'reason'
                                ),
                    ]);
            }
        );

        $booking->loadMissing(
            'provider'
        );

        $booking
            ->provider
            ?->notify(
                new SystemNotification(
                    type:
                        'BOOKING_CANCELLED_BY_CUSTOMER',

                    title:
                        'Khách hàng đã hủy đơn',

                    message:
                        'Khách hàng đã hủy đơn '
                        . $booking->booking_code
                        . '.',

                    audience:
                        'PROVIDER',

                    target:
                        'PROVIDER_BOOKING_DETAIL',

                    bookingId:
                        $booking->id,

                    bookingCode:
                        $booking->booking_code,

                    status:
                        'CANCELLED',
                )
            );

        $booking->load([
            'customer',
            'provider.providerProfile',
            'service',
            'statusHistories.changedByUser',
        ]);

        return response()->json([
            'success' => true,

            'message' =>
                'Hủy đơn thành công.',

            'data' => [
                'booking' =>
                    new BookingResource(
                        $booking
                    ),
            ],
        ]);
    }

    private function generateBookingCode(): string
    {
        do {
            $code =
                'BK-'
                . now()->format(
                    'Ymd'
                )
                . '-'
                . strtoupper(
                    Str::random(6)
                );
        } while (
            Booking::where(
                'booking_code',
                $code
            )->exists()
        );

        return $code;
    }
}