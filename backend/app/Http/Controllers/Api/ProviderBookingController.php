<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Booking\RejectBookingRequest;
use App\Http\Resources\BookingResource;
use App\Models\Booking;
use App\Models\BookingStatusHistory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProviderBookingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $this->ensureProvider($request);

        $validated = $request->validate([
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

        $query = Booking::query()
            ->where(
                'provider_id',
                $request->user()->id
            )
            ->with([
                'customer',
                'service',
            ])
            ->latest();

        if (! empty($validated['status'])) {
            $query->where(
                'status',
                $validated['status']
            );
        }

        $bookings = $query->paginate(
            $validated['per_page'] ?? 10
        );

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy danh sách đơn của nhà cung cấp thành công.',

            'data' => [
                'bookings' =>
                    BookingResource::collection(
                        $bookings->items()
                    ),

                'pagination' => [
                    'current_page' =>
                        $bookings->currentPage(),

                    'last_page' =>
                        $bookings->lastPage(),

                    'per_page' =>
                        $bookings->perPage(),

                    'total' =>
                        $bookings->total(),
                ],
            ],
        ]);
    }

    public function show(
        Request $request,
        Booking $booking
    ): JsonResponse {
        $this->ensureProviderOwnsBooking(
            $request,
            $booking
        );

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
                    new BookingResource($booking),
            ],
        ]);
    }

    public function accept(
        Request $request,
        Booking $booking
    ): JsonResponse {
        $this->ensureProviderOwnsBooking(
            $request,
            $booking
        );

        if ($booking->status !== 'PENDING') {
            return $this->invalidStatus();
        }

        $this->changeStatus(
            booking: $booking,
            userId: $request->user()->id,
            newStatus: 'ACCEPTED',
            note: 'Nhà cung cấp đã chấp nhận yêu cầu.',
            additionalData: [
                'accepted_at' => now(),
            ]
        );

        return $this->statusResponse(
            $booking,
            'Chấp nhận đơn thành công.'
        );
    }

    public function reject(
        RejectBookingRequest $request,
        Booking $booking
    ): JsonResponse {
        $this->ensureProviderOwnsBooking(
            $request,
            $booking
        );

        if ($booking->status !== 'PENDING') {
            return $this->invalidStatus();
        }

        $reason = $request->validated('reason');

        $this->changeStatus(
            booking: $booking,
            userId: $request->user()->id,
            newStatus: 'REJECTED',
            note: $reason,
            additionalData: [
                'rejection_reason' => $reason,
            ]
        );

        return $this->statusResponse(
            $booking,
            'Từ chối đơn thành công.'
        );
    }

    public function start(
        Request $request,
        Booking $booking
    ): JsonResponse {
        $this->ensureProviderOwnsBooking(
            $request,
            $booking
        );

        if ($booking->status !== 'ACCEPTED') {
            return $this->invalidStatus();
        }

        $this->changeStatus(
            booking: $booking,
            userId: $request->user()->id,
            newStatus: 'IN_PROGRESS',
            note: 'Nhà cung cấp bắt đầu thực hiện dịch vụ.',
            additionalData: [
                'started_at' => now(),
            ]
        );

        return $this->statusResponse(
            $booking,
            'Bắt đầu thực hiện dịch vụ thành công.'
        );
    }

    public function complete(
        Request $request,
        Booking $booking
    ): JsonResponse {
        $this->ensureProviderOwnsBooking(
            $request,
            $booking
        );

        if ($booking->status !== 'IN_PROGRESS') {
            return $this->invalidStatus();
        }

        $this->changeStatus(
            booking: $booking,
            userId: $request->user()->id,
            newStatus: 'COMPLETED',
            note: 'Nhà cung cấp đã hoàn thành dịch vụ.',
            additionalData: [
                'completed_at' => now(),
            ]
        );

        return $this->statusResponse(
            $booking,
            'Hoàn thành dịch vụ thành công.'
        );
    }

    private function ensureProvider(
        Request $request
    ): void {
        if ($request->user()->role !== 'PROVIDER') {
            abort(403, 'Bạn không có quyền truy cập.');
        }
    }

    private function ensureProviderOwnsBooking(
        Request $request,
        Booking $booking
    ): void {
        $this->ensureProvider($request);

        if (
            $booking->provider_id !==
            $request->user()->id
        ) {
            abort(
                403,
                'Bạn không có quyền thao tác đơn này.'
            );
        }
    }

    private function changeStatus(
        Booking $booking,
        int $userId,
        string $newStatus,
        string $note,
        array $additionalData = []
    ): void {
        $oldStatus = $booking->status;

        DB::transaction(
            function () use (
                $booking,
                $userId,
                $oldStatus,
                $newStatus,
                $note,
                $additionalData
            ): void {
                $booking->update([
                    'status' => $newStatus,
                    ...$additionalData,
                ]);

                BookingStatusHistory::create([
                    'booking_id' => $booking->id,
                    'changed_by' => $userId,
                    'old_status' => $oldStatus,
                    'new_status' => $newStatus,
                    'note' => $note,
                ]);
            }
        );
    }

    private function invalidStatus(): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' =>
                'Không thể chuyển trạng thái đơn ở trạng thái hiện tại.',
        ], 422);
    }

    private function statusResponse(
        Booking $booking,
        string $message
    ): JsonResponse {
        $booking->refresh();

        $booking->load([
            'customer',
            'provider.providerProfile',
            'service',
            'statusHistories.changedByUser',
        ]);

        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => [
                'booking' =>
                    new BookingResource($booking),
            ],
        ]);
    }
}