<?php

namespace Tests\Feature;

use App\Models\Booking;
use App\Models\ProviderProfile;
use App\Models\Review;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ReviewTest extends TestCase
{
    use RefreshDatabase;

    private function createCustomer(
        array $attributes = []
    ): User {
        return User::factory()->create(
            array_merge([
                'role' => 'CUSTOMER',
                'status' => 'ACTIVE',
            ], $attributes)
        );
    }

    private function createApprovedProvider(): User
    {
        $provider = $this->createCustomer();

        ProviderProfile::create([
            'user_id' => $provider->id,
            'business_name' => 'Provider Test',
            'description' => 'Nhà cung cấp kiểm thử',
            'address' => 'Hà Nội',
            'identity_number' => '012345678901',
            'experience_years' => 3,
            'average_rating' => 0,
            'total_reviews' => 0,
            'verification_status' =>
                ProviderProfile::VERIFICATION_APPROVED,
            'provider_status' =>
                ProviderProfile::STATUS_ACTIVE,
            'verified_at' => now(),
        ]);

        return $provider;
    }

    private function createService(
        User $provider
    ): Service {
        $unique = uniqid();

        $category = ServiceCategory::create([
            'name' => 'Danh mục ' . $unique,
            'slug' => 'category-' . $unique,
            'description' => 'Danh mục test',
            'status' => 'ACTIVE',
        ]);

        return Service::create([
            'category_id' => $category->id,
            'provider_id' => $provider->id,
            'name' => 'Dịch vụ ' . $unique,
            'slug' => 'service-' . $unique,
            'description' => 'Dịch vụ test',
            'price' => 200000,
            'price_unit' => 'Lần',
            'estimated_duration_minutes' => 120,
            'status' => 'ACTIVE',
        ]);
    }

    private function createBooking(
        User $customer,
        User $provider,
        Service $service,
        string $status = 'COMPLETED'
    ): Booking {
        return Booking::create([
            'booking_code' =>
                'BK-TEST-' . strtoupper(
                    substr(uniqid(), -6)
                ),

            'customer_id' => $customer->id,
            'provider_id' => $provider->id,
            'service_id' => $service->id,

            'service_name' => $service->name,
            'unit_price' => $service->price,
            'quantity' => 1,
            'total_amount' => $service->price,

            'booking_date' => now()
                ->subDay()
                ->format('Y-m-d'),

            'booking_time' => '09:00',

            'customer_name' => $customer->name,
            'customer_phone' =>
                $customer->phone ?? '0912345678',

            'service_address' =>
                '123 Nguyễn Trãi, Hà Nội',

            'status' => $status,

            'completed_at' =>
                $status === 'COMPLETED'
                    ? now()
                    : null,
        ]);
    }

    public function test_guest_cannot_create_review(): void
    {
        $customer = $this->createCustomer();

        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService($provider);

        $booking = $this->createBooking(
            $customer,
            $provider,
            $service
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/review",
            [
                'rating' => 5,
                'comment' => 'Dịch vụ rất tốt.',
            ]
        );

        $response->assertUnauthorized();
    }

    public function test_customer_can_review_completed_booking(): void
    {
        $customer =
            $this->createCustomer();

        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService($provider);

        $booking = $this->createBooking(
            $customer,
            $provider,
            $service,
            'COMPLETED'
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/review",
            [
                'rating' => 5,
                'comment' =>
                    'Dịch vụ rất tốt.',
            ]
        );

        $response
            ->assertCreated()
            ->assertJsonPath(
                'success',
                true
            )
            ->assertJsonPath(
                'message',
                'Đánh giá dịch vụ thành công.'
            )
            ->assertJsonPath(
                'data.review.rating',
                5
            );

        $this->assertDatabaseHas(
            'reviews',
            [
                'booking_id' =>
                    $booking->id,
                'customer_id' =>
                    $customer->id,
                'provider_id' =>
                    $provider->id,
                'rating' => 5,
                'status' => 'VISIBLE',
            ]
        );
    }

    public function test_review_rating_must_be_between_one_and_five(): void
    {
        $customer =
            $this->createCustomer();

        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService($provider);

        $booking = $this->createBooking(
            $customer,
            $provider,
            $service
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/review",
            [
                'rating' => 6,
                'comment' => 'Test rating',
            ]
        );

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'rating',
            ]);

        $this->assertDatabaseCount(
            'reviews',
            0
        );
    }

    public function test_customer_cannot_review_uncompleted_booking(): void
    {
        $customer =
            $this->createCustomer();

        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService($provider);

        $booking = $this->createBooking(
            $customer,
            $provider,
            $service,
            'IN_PROGRESS'
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/review",
            [
                'rating' => 5,
            ]
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'success',
                false
            )
            ->assertJsonPath(
                'message',
                'Chỉ có thể đánh giá đơn đã hoàn thành.'
            );

        $this->assertDatabaseCount(
            'reviews',
            0
        );
    }

    public function test_customer_cannot_review_another_customer_booking(): void
    {
        $customer =
            $this->createCustomer();

        $otherCustomer =
            $this->createCustomer();

        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService($provider);

        $booking = $this->createBooking(
            $otherCustomer,
            $provider,
            $service
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/review",
            [
                'rating' => 5,
            ]
        );

        $response->assertForbidden();

        $this->assertDatabaseCount(
            'reviews',
            0
        );
    }

    public function test_booking_cannot_be_reviewed_twice(): void
    {
        $customer =
            $this->createCustomer();

        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService($provider);

        $booking = $this->createBooking(
            $customer,
            $provider,
            $service
        );

        Review::create([
            'booking_id' => $booking->id,
            'customer_id' => $customer->id,
            'provider_id' => $provider->id,
            'rating' => 4,
            'comment' => 'Đánh giá đầu tiên.',
            'status' => 'VISIBLE',
        ]);

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/review",
            [
                'rating' => 5,
                'comment' =>
                    'Đánh giá lần hai.',
            ]
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'success',
                false
            )
            ->assertJsonPath(
                'message',
                'Đơn này đã được đánh giá trước đó.'
            );

        $this->assertDatabaseCount(
            'reviews',
            1
        );
    }

    public function test_review_updates_provider_rating_statistics(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customerOne =
            $this->createCustomer();

        $customerTwo =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $bookingOne = $this->createBooking(
            $customerOne,
            $provider,
            $service
        );

        $bookingTwo = $this->createBooking(
            $customerTwo,
            $provider,
            $service
        );

        Sanctum::actingAs(
            $customerOne,
            ['mobile']
        );

        $this->postJson(
            "/api/bookings/{$bookingOne->id}/review",
            [
                'rating' => 5,
            ]
        )->assertCreated();

        Sanctum::actingAs(
            $customerTwo,
            ['mobile']
        );

        $this->postJson(
            "/api/bookings/{$bookingTwo->id}/review",
            [
                'rating' => 3,
            ]
        )->assertCreated();

        $profile = ProviderProfile::query()
            ->where(
                'user_id',
                $provider->id
            )
            ->firstOrFail();

        $this->assertSame(
            2,
            $profile->total_reviews
        );

        $this->assertSame(
            '4.00',
            $profile->average_rating
        );
    }
}