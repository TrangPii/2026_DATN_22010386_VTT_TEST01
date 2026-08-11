<?php

namespace Tests\Feature;

use App\Models\ProviderProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminAuthorizationTest extends TestCase
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

    private function createAdmin(
        array $attributes = []
    ): User {
        return User::factory()->create(
            array_merge([
                'role' => 'ADMIN',
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

            'verification_status' =>
                ProviderProfile::VERIFICATION_APPROVED,

            'provider_status' =>
                ProviderProfile::STATUS_ACTIVE,

            'verified_at' => now(),
        ]);

        return $provider;
    }

    public function test_guest_cannot_access_admin_dashboard(): void
    {
        $response = $this->getJson(
            '/api/admin/dashboard'
        );

        $response->assertUnauthorized();
    }

    public function test_customer_cannot_access_admin_dashboard(): void
    {
        $customer = $this->createCustomer();

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/admin/dashboard'
        );

        $response
            ->assertForbidden()
            ->assertJsonPath(
                'success',
                false
            )
            ->assertJsonPath(
                'message',
                'Bạn không có quyền truy cập chức năng này.'
            );
    }

    public function test_provider_cannot_access_admin_dashboard(): void
    {
        $provider =
            $this->createApprovedProvider();

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/admin/dashboard'
        );

        $response
            ->assertForbidden()
            ->assertJsonPath(
                'message',
                'Bạn không có quyền truy cập chức năng này.'
            );
    }

    public function test_inactive_admin_cannot_access_admin_dashboard(): void
    {
        $admin = $this->createAdmin([
            'status' => 'LOCKED',
        ]);

        Sanctum::actingAs(
            $admin,
            ['admin']
        );

        $response = $this->getJson(
            '/api/admin/dashboard'
        );

        $response
            ->assertForbidden()
            ->assertJsonPath(
                'message',
                'Bạn không có quyền truy cập chức năng này.'
            );
    }

    public function test_active_admin_can_access_admin_dashboard(): void
    {
        $admin = $this->createAdmin();

        Sanctum::actingAs(
            $admin,
            ['admin']
        );

        $response = $this->getJson(
            '/api/admin/dashboard'
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'success',
                true
            )
            ->assertJsonPath(
                'message',
                'Lấy dữ liệu dashboard thành công.'
            );

        $response->assertJsonStructure([
            'data' => [
                'users' => [
                    'total',
                    'customers',
                    'providers',
                    'locked',
                ],
                'providers' => [
                    'pending',
                    'approved',
                    'rejected',
                ],
                'services' => [
                    'total',
                    'active',
                    'inactive',
                    'categories',
                ],
                'bookings' => [
                    'total',
                    'pending',
                    'in_progress',
                    'completed',
                    'cancelled',
                ],
                'revenue' => [
                    'completed_booking_value',
                ],
            ],
        ]);
    }

    public function test_customer_cannot_access_admin_users(): void
    {
        $customer = $this->createCustomer();

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/admin/users'
        );

        $response->assertForbidden();
    }

    public function test_customer_cannot_access_admin_providers(): void
    {
        $customer = $this->createCustomer();

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/admin/providers'
        );

        $response->assertForbidden();
    }

    public function test_customer_cannot_access_admin_categories(): void
    {
        $customer = $this->createCustomer();

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/admin/categories'
        );

        $response->assertForbidden();
    }

    public function test_customer_cannot_access_admin_services(): void
    {
        $customer = $this->createCustomer();

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/admin/services'
        );

        $response->assertForbidden();
    }

    public function test_customer_cannot_access_admin_bookings(): void
    {
        $customer = $this->createCustomer();

        Sanctum::actingAs(
            $customer,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/admin/bookings'
        );

        $response->assertForbidden();
    }

    public function test_active_admin_can_access_main_admin_resources(): void
    {
        $admin = $this->createAdmin();

        Sanctum::actingAs(
            $admin,
            ['admin']
        );

        $this->getJson('/api/admin/users')
            ->assertOk();

        $this->getJson('/api/admin/providers')
            ->assertOk();

        $this->getJson('/api/admin/categories')
            ->assertOk();

        $this->getJson('/api/admin/services')
            ->assertOk();

        $this->getJson('/api/admin/bookings')
            ->assertOk();
    }
}