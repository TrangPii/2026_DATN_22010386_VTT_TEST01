<?php

namespace Tests\Feature;

use App\Models\ProviderProfile;
use App\Models\Service;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProviderServiceTest extends TestCase
{
    use RefreshDatabase;

    private function createApprovedProvider(): User
    {
        $provider = User::factory()->create([
            'role' => 'CUSTOMER',
            'status' => 'ACTIVE',
        ]);

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

    private function createCategory(
        string $status = 'ACTIVE'
    ): ServiceCategory {
        $unique = uniqid();

        return ServiceCategory::create([
            'name' => 'Danh mục ' . $unique,
            'slug' => 'category-' . $unique,
            'description' => 'Danh mục kiểm thử',
            'status' => $status,
        ]);
    }

    private function createService(
        User $provider,
        ?ServiceCategory $category = null,
        array $attributes = []
    ): Service {
        $category ??= $this->createCategory();

        $unique = uniqid();

        return Service::create(
            array_merge([
                'category_id' => $category->id,
                'provider_id' => $provider->id,
                'name' => 'Dịch vụ ' . $unique,
                'slug' => 'service-' . $unique,
                'description' => 'Dịch vụ kiểm thử',
                'price' => 200000,
                'price_unit' => 'Lần',
                'estimated_duration_minutes' => 120,
                'status' => 'ACTIVE',
            ], $attributes)
        );
    }

    private function validPayload(
        ServiceCategory $category,
        array $overrides = []
    ): array {
        return array_merge([
            'category_id' => $category->id,
            'name' => 'Vệ sinh nhà cửa',
            'description' =>
                'Dịch vụ vệ sinh nhà cửa.',
            'price' => 250000,
            'price_unit' => 'Lần',
            'estimated_duration_minutes' => 120,
        ], $overrides);
    }

    public function test_guest_cannot_access_provider_services(): void
    {
        $response = $this->getJson(
            '/api/provider/services'
        );

        $response->assertUnauthorized();
    }

    public function test_unapproved_user_cannot_access_provider_services(): void
    {
        $user = User::factory()->create([
            'role' => 'CUSTOMER',
            'status' => 'ACTIVE',
        ]);

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/provider/services'
        );

        $response->assertForbidden();
    }

    public function test_provider_only_sees_own_services(): void
    {
        $provider =
            $this->createApprovedProvider();

        $otherProvider =
            $this->createApprovedProvider();

        $this->createService($provider);

        $this->createService(
            $otherProvider
        );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/provider/services'
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.pagination.total',
                1
            );

        $response->assertJsonCount(
            1,
            'data.services'
        );
    }

    public function test_provider_can_create_service(): void
    {
        $provider =
            $this->createApprovedProvider();

        $category =
            $this->createCategory();

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider/services',
            $this->validPayload(
                $category
            )
        );

        $response
            ->assertCreated()
            ->assertJsonPath(
                'success',
                true
            )
            ->assertJsonPath(
                'message',
                'Tạo dịch vụ thành công.'
            )
            ->assertJsonPath(
                'data.service.name',
                'Vệ sinh nhà cửa'
            )
            ->assertJsonPath(
                'data.service.status',
                'ACTIVE'
            );

        $this->assertDatabaseHas(
            'services',
            [
                'provider_id' =>
                    $provider->id,
                'category_id' =>
                    $category->id,
                'name' =>
                    'Vệ sinh nhà cửa',
                'status' =>
                    'ACTIVE',
            ]
        );
    }

    public function test_create_service_requires_valid_data(): void
    {
        $provider =
            $this->createApprovedProvider();

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider/services',
            [
                'category_id' => 999999,
                'name' => 'A',
                'price' => -1,
                'price_unit' => '',
                'estimated_duration_minutes' => 0,
            ]
        );

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'category_id',
                'name',
                'price',
                'price_unit',
                'estimated_duration_minutes',
            ]);
    }

    public function test_provider_cannot_create_service_in_inactive_category(): void
    {
        $provider =
            $this->createApprovedProvider();

        $category =
            $this->createCategory(
                'INACTIVE'
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider/services',
            $this->validPayload(
                $category
            )
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'message',
                'Danh mục dịch vụ hiện không hoạt động.'
            );

        $this->assertDatabaseCount(
            'services',
            0
        );
    }

    public function test_provider_can_update_own_service(): void
    {
        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService(
                $provider
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->putJson(
            "/api/provider/services/{$service->id}",
            [
                'name' =>
                    'Dịch vụ đã cập nhật',
                'price' => 350000,
            ]
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'success',
                true
            )
            ->assertJsonPath(
                'data.service.name',
                'Dịch vụ đã cập nhật'
            );

        $this->assertDatabaseHas(
            'services',
            [
                'id' => $service->id,
                'name' =>
                    'Dịch vụ đã cập nhật',
                'price' => 350000,
            ]
        );
    }

    public function test_provider_cannot_update_another_provider_service(): void
    {
        $provider =
            $this->createApprovedProvider();

        $otherProvider =
            $this->createApprovedProvider();

        $service =
            $this->createService(
                $otherProvider
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->putJson(
            "/api/provider/services/{$service->id}",
            [
                'name' =>
                    'Tên bị sửa trái phép',
            ]
        );

        $response->assertForbidden();

        $this->assertDatabaseMissing(
            'services',
            [
                'id' => $service->id,
                'name' =>
                    'Tên bị sửa trái phép',
            ]
        );
    }

    public function test_provider_can_change_service_status(): void
    {
        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService(
                $provider
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->patchJson(
            "/api/provider/services/{$service->id}/status",
            [
                'status' =>
                    'INACTIVE',
            ]
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.service.status',
                'INACTIVE'
            );

        $this->assertDatabaseHas(
            'services',
            [
                'id' => $service->id,
                'status' => 'INACTIVE',
            ]
        );
    }

    public function test_service_status_only_accepts_active_or_inactive(): void
    {
        $provider =
            $this->createApprovedProvider();

        $service =
            $this->createService(
                $provider
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->patchJson(
            "/api/provider/services/{$service->id}/status",
            [
                'status' =>
                    'DELETED',
            ]
        );

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'status',
            ]);

        $this->assertDatabaseHas(
            'services',
            [
                'id' => $service->id,
                'status' => 'ACTIVE',
            ]
        );
    }

    public function test_provider_cannot_change_another_provider_service_status(): void
    {
        $provider =
            $this->createApprovedProvider();

        $otherProvider =
            $this->createApprovedProvider();

        $service =
            $this->createService(
                $otherProvider
            );

        Sanctum::actingAs(
            $provider,
            ['mobile']
        );

        $response = $this->patchJson(
            "/api/provider/services/{$service->id}/status",
            [
                'status' =>
                    'INACTIVE',
            ]
        );

        $response->assertForbidden();

        $this->assertDatabaseHas(
            'services',
            [
                'id' => $service->id,
                'status' => 'ACTIVE',
            ]
        );
    }
}