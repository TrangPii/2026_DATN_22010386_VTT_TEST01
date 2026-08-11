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

class BookingTest extends TestCase
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

    private function createAvailableService(
        ?User $provider = null,
        array $serviceAttributes = []
    ): Service {
        $provider ??= $this->createCustomer();

        ProviderProfile::create([
            'user_id' => $provider->id,
            'business_name' => 'Test Provider',
            'description' => 'Nhà cung cấp kiểm thử',
            'address' => 'Hà Nội',
            'identity_number' => '012345678901',
            'experience_years' => 3,
            'verification_status' =>
                ProviderProfile::VERIFICATION_APPROVED,
            'provider_status' =>
                ProviderProfile::STATUS_ACTIVE,
            'verified_at' => now(),
        ]);

        $category = ServiceCategory::create([
            'name' => 'Dọn dẹp',
            'slug' => 'don-dep-' . uniqid(),
            'description' => 'Danh mục kiểm thử',
            'status' => 'ACTIVE',
        ]);

        return Service::create(
            array_merge([
                'category_id' => $category->id,
                'provider_id' => $provider->id,
                'name' => 'Dọn dẹp nhà cửa',
                'slug' => 'don-dep-' . uniqid(),
                'description' => 'Dịch vụ kiểm thử',
                'price' => 200000,
                'price_unit' => 'Lần',
                'estimated_duration_minutes' => 120,
                'status' => 'ACTIVE',
            ], $serviceAttributes)
        );
    }

    private function validBookingPayload(
        Service $service,
        array $overrides = []
    ): array {
        return array_merge([
            'service_id' => $service->id,
            'booking_date' => now()
                ->addDay()
                ->format('Y-m-d'),
            'booking_time' => '09:00',
            'quantity' => 2,
            'customer_name' => 'Nguyen Van A',
            'customer_phone' => '0912345678',
            'service_address' =>
                '123 Nguyen Trai, Ha Noi',
            'note' => 'Vui lòng đến đúng giờ',
        ], $overrides);
    }

    private function createBooking(
        User $customer,
        Service $service,
        string $status = 'PENDING'
    ): Booking {
        return Booking::create([
            'booking_code' =>
                'BK-TEST-' . strtoupper(
                    substr(uniqid(), -6)
                ),

            'customer_id' => $customer->id,
            'provider_id' => $service->provider_id,
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
                '123 Nguyen Trai, Ha Noi',

            'note' => null,
            'status' => $status,
        ]);
    }

    public function test_guest_cannot_access_bookings(): void
    {
        $response = $this->getJson('/api/bookings');

        $response->assertUnauthorized();
    }

    public function test_customer_can_create_booking_successfully(): void
    {
        $customer = $this->createCustomer();

        $service = $this->createAvailableService();

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/bookings',
            $this->validBookingPayload($service)
        );

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath(
                'message',
                'Đặt dịch vụ thành công.'
            )
            ->assertJsonPath(
                'data.booking.status',
                'PENDING'
            );

        $this->assertDatabaseHas('bookings', [
            'customer_id' => $customer->id,
            'provider_id' => $service->provider_id,
            'service_id' => $service->id,
            'status' => 'PENDING',
            'quantity' => 2,
        ]);

        $booking = Booking::where(
            'customer_id',
            $customer->id
        )->firstOrFail();

        $this->assertDatabaseHas(
            'booking_status_histories',
            [
                'booking_id' => $booking->id,
                'changed_by' => $customer->id,
                'old_status' => null,
                'new_status' => 'PENDING',
            ]
        );
    }

    public function test_booking_requires_valid_data(): void
    {
        $customer = $this->createCustomer();

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/bookings',
            [
                'service_id' => 999999,
                'booking_date' => now()
                    ->subDay()
                    ->format('Y-m-d'),
                'booking_time' => '99:99',
                'quantity' => 0,
                'customer_name' => '',
                'customer_phone' => '123',
                'service_address' => '',
            ]
        );

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'service_id',
                'booking_date',
                'booking_time',
                'quantity',
                'customer_name',
                'customer_phone',
                'service_address',
            ]);
    }

    public function test_customer_cannot_book_inactive_service(): void
    {
        $customer = $this->createCustomer();

        $service = $this->createAvailableService(
            null,
            [
                'status' => 'INACTIVE',
            ]
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/bookings',
            $this->validBookingPayload($service)
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonPath(
                'message',
                'Dịch vụ hiện không khả dụng.'
            );

        $this->assertDatabaseCount(
            'bookings',
            0
        );
    }

    public function test_customer_cannot_book_own_service(): void
    {
        $customer = $this->createCustomer();

        $service = $this->createAvailableService(
            $customer
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/bookings',
            $this->validBookingPayload($service)
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'message',
                'Bạn không thể đặt dịch vụ của chính mình.'
            );

        $this->assertDatabaseCount(
            'bookings',
            0
        );
    }

    public function test_customer_only_sees_own_bookings(): void
    {
        $customer = $this->createCustomer();

        $otherCustomer =
            $this->createCustomer();

        $service =
            $this->createAvailableService();

        $this->createBooking(
            $customer,
            $service
        );

        $this->createBooking(
            $otherCustomer,
            $service
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response =
            $this->getJson('/api/bookings');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath(
                'data.pagination.total',
                1
            );

        $response->assertJsonCount(
            1,
            'data.bookings'
        );
    }

    public function test_customer_cannot_view_another_customer_booking(): void
    {
        $customer = $this->createCustomer();

        $otherCustomer =
            $this->createCustomer();

        $service =
            $this->createAvailableService();

        $booking = $this->createBooking(
            $otherCustomer,
            $service
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->getJson(
            "/api/bookings/{$booking->id}"
        );

        $response->assertForbidden();
    }

    public function test_customer_can_cancel_pending_booking(): void
    {
        $customer =
            $this->createCustomer();

        $service =
            $this->createAvailableService();

        $booking = $this->createBooking(
            $customer,
            $service,
            'PENDING'
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/cancel",
            [
                'reason' =>
                    'Tôi thay đổi kế hoạch.',
            ]
        );

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath(
                'message',
                'Hủy đơn thành công.'
            )
            ->assertJsonPath(
                'data.booking.status',
                'CANCELLED'
            );

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'CANCELLED',
                'cancellation_reason' =>
                    'Tôi thay đổi kế hoạch.',
            ]
        );

        $this->assertNotNull(
            $booking
                ->fresh()
                ->cancelled_at
        );

        $this->assertDatabaseHas(
            'booking_status_histories',
            [
                'booking_id' =>
                    $booking->id,
                'old_status' =>
                    'PENDING',
                'new_status' =>
                    'CANCELLED',
            ]
        );
    }

    public function test_customer_can_cancel_accepted_booking(): void
    {
        $customer =
            $this->createCustomer();

        $service =
            $this->createAvailableService();

        $booking = $this->createBooking(
            $customer,
            $service,
            'ACCEPTED'
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/cancel",
            [
                'reason' =>
                    'Không còn nhu cầu sử dụng.',
            ]
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.booking.status',
                'CANCELLED'
            );

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'CANCELLED',
            ]
        );
    }

    public function test_customer_cannot_cancel_completed_booking(): void
    {
        $customer =
            $this->createCustomer();

        $service =
            $this->createAvailableService();

        $booking = $this->createBooking(
            $customer,
            $service,
            'COMPLETED'
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/cancel",
            [
                'reason' =>
                    'Muốn hủy đơn.',
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
                'Đơn ở trạng thái hiện tại không thể hủy.'
            );

        $this->assertDatabaseHas(
            'bookings',
            [
                'id' => $booking->id,
                'status' => 'COMPLETED',
            ]
        );
    }

    public function test_cancellation_requires_reason(): void
    {
        $customer =
            $this->createCustomer();

        $service =
            $this->createAvailableService();

        $booking = $this->createBooking(
            $customer,
            $service
        );

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->postJson(
            "/api/bookings/{$booking->id}/cancel",
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
}