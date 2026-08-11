<?php

namespace Tests\Feature;

use App\Models\Booking;
use App\Models\ProviderProfile;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProviderBookingTest extends TestCase
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

    private function createApprovedProvider(
        array $userAttributes = [],
        array $profileAttributes = []
    ): User {
        $provider = $this->createCustomer(
            $userAttributes
        );

        ProviderProfile::create(
            array_merge([
                'user_id' => $provider->id,
                'business_name' => 'Provider Test',
                'description' => 'Nhà cung cấp kiểm thử',
                'address' => 'Hà Nội',
                'identity_number' => '012345678901',
                'experience_years' => 3,
                'verification_status' =>
                    ProviderProfile::VERIFICATION_APPROVED,
                'provider_status' =>
                    ProviderProfile::STATUS_ACTIVE,
                'verified_at' => now(),
            ], $profileAttributes)
        );

        return $provider;
    }

    private function createService(
        User $provider
    ): Service {
        $unique = uniqid();

        $category = ServiceCategory::create([
            'name' => 'Dọn dẹp ' . $unique,
            'slug' => 'don-dep-' . $unique,
            'description' => 'Danh mục test',
            'status' => 'ACTIVE',
        ]);

        return Service::create([
            'category_id' => $category->id,
            'provider_id' => $provider->id,
            'name' => 'Dọn dẹp nhà cửa ' . $unique,
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
        string $status = 'PENDING'
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
                ->addDay()
                ->format('Y-m-d'),

            'booking_time' => '09:00',
            'customer_name' => $customer->name,
            'customer_phone' =>
                $customer->phone ?? '0912345678',

            'service_address' =>
                '123 Nguyễn Trãi, Hà Nội',

            'status' => $status,
        ]);
    }

    public function test_guest_cannot_access_provider_bookings(): void
    {
        $response = $this->getJson(
            '/api/provider/bookings'
        );

        $response->assertUnauthorized();
    }

    public function test_unapproved_user_cannot_access_provider_bookings(): void
    {
        $user = $this->createCustomer();

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/provider/bookings'
        );

        $response
            ->assertForbidden()
            ->assertJsonPath(
                'message',
                'Bạn chưa được cấp quyền Nhà cung cấp.'
            );
    }

    public function test_provider_only_sees_own_bookings(): void
    {
        $provider =
            $this->createApprovedProvider();

        $otherProvider =
            $this->createApprovedProvider();

        $customer = $this->createCustomer();

        $service =
            $this->createService($provider);

        $otherService =
            $this->createService($otherProvider);

        $this->createBooking(
            $customer,
            $provider,
            $service
        );

        $this->createBooking(
            $customer,
            $otherProvider,
            $otherService
        );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/provider/bookings'
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.pagination.total',
                1
            );

        $response->assertJsonCount(
            1,
            'data.bookings'
        );
    }

    public function test_provider_cannot_view_another_provider_booking(): void
    {
        $provider =
            $this->createApprovedProvider();

        $otherProvider =
            $this->createApprovedProvider();

        $customer = $this->createCustomer();

        $service =
            $this->createService(
                $otherProvider
            );

        $booking = $this->createBooking(
            $customer,
            $otherProvider,
            $service
        );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->getJson(
            "/api/provider/bookings/{$booking->id}"
        );

        $response->assertForbidden();
    }

    public function test_provider_can_accept_pending_booking(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customer =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $booking =
            $this->createBooking(
                $customer,
                $provider,
                $service,
                'PENDING'
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/provider/bookings/{$booking->id}/accept"
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'success',
                true
            )
            ->assertJsonPath(
                'data.booking.status',
                'ACCEPTED'
            );

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'ACCEPTED',
            ]
        );

        $this->assertNotNull(
            $booking
                ->fresh()
                ->accepted_at
        );

        $this->assertDatabaseHas(
            'booking_status_histories',
            [
                'booking_id' =>
                    $booking->id,
                'changed_by' =>
                    $provider->id,
                'old_status' =>
                    'PENDING',
                'new_status' =>
                    'ACCEPTED',
            ]
        );
    }

    public function test_provider_can_reject_pending_booking(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customer =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $booking =
            $this->createBooking(
                $customer,
                $provider,
                $service,
                'PENDING'
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/provider/bookings/{$booking->id}/reject",
            [
                'reason' =>
                    'Không thể nhận lịch này.',
            ]
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'success',
                true
            )
            ->assertJsonPath(
                'data.booking.status',
                'REJECTED'
            );

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'REJECTED',
                'rejection_reason' =>
                    'Không thể nhận lịch này.',
            ]
        );

        $this->assertDatabaseHas(
            'booking_status_histories',
            [
                'booking_id' =>
                    $booking->id,
                'old_status' =>
                    'PENDING',
                'new_status' =>
                    'REJECTED',
            ]
        );
    }

    public function test_reject_requires_reason(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customer =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $booking =
            $this->createBooking(
                $customer,
                $provider,
                $service
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/provider/bookings/{$booking->id}/reject",
            []
        );

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'reason',
            ]);

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'PENDING',
            ]
        );
    }

    public function test_provider_can_start_accepted_booking(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customer =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $booking =
            $this->createBooking(
                $customer,
                $provider,
                $service,
                'ACCEPTED'
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/provider/bookings/{$booking->id}/start"
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.booking.status',
                'IN_PROGRESS'
            );

        $this->assertNotNull(
            $booking
                ->fresh()
                ->started_at
        );

        $this->assertDatabaseHas(
            'booking_status_histories',
            [
                'booking_id' =>
                    $booking->id,
                'old_status' =>
                    'ACCEPTED',
                'new_status' =>
                    'IN_PROGRESS',
            ]
        );
    }

    public function test_provider_can_complete_in_progress_booking(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customer =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $booking =
            $this->createBooking(
                $customer,
                $provider,
                $service,
                'IN_PROGRESS'
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/provider/bookings/{$booking->id}/complete"
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.booking.status',
                'COMPLETED'
            );

        $this->assertNotNull(
            $booking
                ->fresh()
                ->completed_at
        );

        $this->assertDatabaseHas(
            'booking_status_histories',
            [
                'booking_id' =>
                    $booking->id,
                'old_status' =>
                    'IN_PROGRESS',
                'new_status' =>
                    'COMPLETED',
            ]
        );
    }

    public function test_provider_cannot_start_pending_booking(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customer =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $booking =
            $this->createBooking(
                $customer,
                $provider,
                $service,
                'PENDING'
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/provider/bookings/{$booking->id}/start"
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'success',
                false
            )
            ->assertJsonPath(
                'message',
                'Không thể chuyển trạng thái đơn ở trạng thái hiện tại.'
            );

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'PENDING',
            ]
        );
    }

    public function test_provider_cannot_complete_accepted_booking(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customer =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $booking =
            $this->createBooking(
                $customer,
                $provider,
                $service,
                'ACCEPTED'
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/provider/bookings/{$booking->id}/complete"
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'success',
                false
            );

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'ACCEPTED',
            ]
        );
    }

    public function test_provider_cannot_accept_booking_twice(): void
    {
        $provider =
            $this->createApprovedProvider();

        $customer =
            $this->createCustomer();

        $service =
            $this->createService($provider);

        $booking =
            $this->createBooking(
                $customer,
                $provider,
                $service,
                'ACCEPTED'
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/provider/bookings/{$booking->id}/accept"
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'success',
                false
            );

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'ACCEPTED',
            ]
        );
    }
}