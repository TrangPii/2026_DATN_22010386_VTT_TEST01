<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Review\StoreReviewRequest;
use App\Http\Resources\ReviewResource;
use App\Models\Booking;
use App\Models\ProviderProfile;
use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReviewController extends Controller
{
    /**
     * Customer tạo đánh giá cho booking đã hoàn thành.
     */
    public function store(
        StoreReviewRequest $request,
        Booking $booking
    ): JsonResponse {
        if (
            $booking->customer_id !==
            $request->user()->id
        ) {
            abort(
                403,
                'Bạn không có quyền đánh giá đơn này.'
            );
        }

        if ($booking->status !== 'COMPLETED') {
            return response()->json([
                'success' => false,
                'message' =>
                    'Chỉ có thể đánh giá đơn đã hoàn thành.',
            ], 422);
        }

        if ($booking->review()->exists()) {
            return response()->json([
                'success' => false,
                'message' =>
                    'Đơn này đã được đánh giá trước đó.',
            ], 422);
        }

        $validated = $request->validated();

        $review = DB::transaction(
            function () use (
                $request,
                $booking,
                $validated
            ): Review {
                $review = Review::create([
                    'booking_id' =>
                        $booking->id,

                    'customer_id' =>
                        $request->user()->id,

                    'provider_id' =>
                        $booking->provider_id,

                    'rating' =>
                        $validated['rating'],

                    'comment' =>
                        $validated['comment'] ?? null,

                    'status' =>
                        'VISIBLE',
                ]);

                $this->updateProviderRating(
                    $booking->provider_id
                );

                return $review;
            }
        );

        $review->load([
            'customer',
            'provider',
            'booking',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Đánh giá dịch vụ thành công.',
            'data' => [
                'review' =>
                    new ReviewResource($review),
            ],
        ], 201);
    }

    /**
     * Xem danh sách review của provider.
     */
    public function providerReviews(
        Request $request,
        int $providerId
    ): JsonResponse {
        $validated = $request->validate([
            'rating' => [
                'nullable',
                'integer',
                'between:1,5',
            ],

            'per_page' => [
                'nullable',
                'integer',
                'min:1',
                'max:50',
            ],
        ]);

        $query = Review::query()
            ->where('provider_id', $providerId)
            ->where('status', 'VISIBLE')
            ->with([
                'customer',
                'booking',
            ])
            ->latest();

        if (isset($validated['rating'])) {
            $query->where(
                'rating',
                $validated['rating']
            );
        }

        $reviews = $query->paginate(
            $validated['per_page'] ?? 10
        );

        return response()->json([
            'success' => true,
            'message' =>
                'Lấy danh sách đánh giá thành công.',

            'data' => [
                'reviews' =>
                    ReviewResource::collection(
                        $reviews->items()
                    ),

                'pagination' => [
                    'current_page' =>
                        $reviews->currentPage(),

                    'last_page' =>
                        $reviews->lastPage(),

                    'per_page' =>
                        $reviews->perPage(),

                    'total' =>
                        $reviews->total(),
                ],
            ],
        ]);
    }

    /**
     * Tính lại điểm trung bình provider.
     */
    private function updateProviderRating(
        int $providerId
    ): void {
        $stats = Review::query()
            ->where('provider_id', $providerId)
            ->where('status', 'VISIBLE')
            ->selectRaw(
                'COUNT(*) as total_reviews, AVG(rating) as average_rating'
            )
            ->first();

        ProviderProfile::query()
            ->where('user_id', $providerId)
            ->update([
                'average_rating' =>
                    round(
                        (float) ($stats->average_rating ?? 0),
                        2
                    ),

                'total_reviews' =>
                    (int) $stats->total_reviews,
            ]);
    }
}