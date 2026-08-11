<?php

namespace Tests\Feature;

use App\Models\ProviderProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProviderApplicationTest extends TestCase
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

    private function validPayload(
        array $overrides = []
    ): array {
        return array_merge([
            'business_name' => 'Dịch vụ An Tâm',
            'description' => 'Cung cấp dịch vụ tại nhà.',
            'address' => '123 Nguyễn Trãi, Hà Nội',
            'identity_number' => '012345678901',
            'experience_years' => 3,
        ], $overrides);
    }

    public function test_guest_cannot_view_provider_application(): void
    {
        $response = $this->getJson(
            '/api/provider-application'
        );

        $response->assertUnauthorized();
    }

    public function test_customer_without_application_gets_null(): void
    {
        $user = $this->createCustomer();

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->getJson(
            '/api/provider-application'
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'data.application',
                null
            );
    }

    public function test_customer_can_submit_provider_application(): void
    {
        $user = $this->createCustomer();

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider-application',
            $this->validPayload()
        );

        $response
            ->assertCreated()
            ->assertJsonPath(
                'message',
                'Đã gửi yêu cầu đăng ký nhà cung cấp.'
            )
            ->assertJsonPath(
                'data.application.user_id',
                $user->id
            )
            ->assertJsonPath(
                'data.application.verification_status',
                'PENDING'
            );

        $this->assertDatabaseHas(
            'provider_profiles',
            [
                'user_id' => $user->id,
                'business_name' =>
                    'Dịch vụ An Tâm',
                'verification_status' =>
                    'PENDING',
            ]
        );
    }

    public function test_provider_application_requires_valid_data(): void
    {
        $user = $this->createCustomer();

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider-application',
            [
                'business_name' => '',
                'address' => '',
                'identity_number' => '',
                'experience_years' => -1,
            ]
        );

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'business_name',
                'address',
                'identity_number',
                'experience_years',
            ]);

        $this->assertDatabaseCount(
            'provider_profiles',
            0
        );
    }

    public function test_inactive_user_cannot_submit_provider_application(): void
    {
        $user = $this->createCustomer([
            'status' => 'INACTIVE',
        ]);

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider-application',
            $this->validPayload()
        );

        $response
            ->assertForbidden()
            ->assertJsonPath(
                'message',
                'Tài khoản hiện không khả dụng.'
            );

        $this->assertDatabaseCount(
            'provider_profiles',
            0
        );
    }

    public function test_pending_application_cannot_be_submitted_again(): void
    {
        $user = $this->createCustomer();

        ProviderProfile::create([
            'user_id' => $user->id,
            'business_name' => 'Provider cũ',
            'description' => null,
            'address' => 'Hà Nội',
            'identity_number' =>
                '012345678901',
            'experience_years' => 2,
            'verification_status' =>
                ProviderProfile::VERIFICATION_PENDING,
            'provider_status' => null,
        ]);

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider-application',
            $this->validPayload()
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'message',
                'Yêu cầu của bạn đang chờ Admin xác minh.'
            );

        $this->assertDatabaseCount(
            'provider_profiles',
            1
        );
    }

    public function test_approved_provider_cannot_submit_application_again(): void
    {
        $user = $this->createCustomer();

        ProviderProfile::create([
            'user_id' => $user->id,
            'business_name' =>
                'Provider đã duyệt',
            'description' => null,
            'address' => 'Hà Nội',
            'identity_number' =>
                '012345678901',
            'experience_years' => 5,
            'verification_status' =>
                ProviderProfile::VERIFICATION_APPROVED,
            'provider_status' =>
                ProviderProfile::STATUS_ACTIVE,
            'verified_at' => now(),
        ]);

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider-application',
            $this->validPayload()
        );

        $response
            ->assertUnprocessable()
            ->assertJsonPath(
                'message',
                'Tài khoản đã được xác minh là nhà cung cấp.'
            );
    }

    public function test_rejected_application_can_be_resubmitted(): void
    {
        $user = $this->createCustomer();

        $profile = ProviderProfile::create([
            'user_id' => $user->id,
            'business_name' => 'Tên cũ',
            'description' => 'Thông tin cũ',
            'address' => 'Địa chỉ cũ',
            'identity_number' =>
                '111111111111',
            'experience_years' => 1,
            'verification_status' =>
                ProviderProfile::VERIFICATION_REJECTED,
            'provider_status' => null,
            'verified_at' => now(),
        ]);

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->postJson(
            '/api/provider-application',
            $this->validPayload([
                'business_name' =>
                    'Dịch vụ Mới',
                'experience_years' => 4,
            ])
        );

        $response
            ->assertOk()
            ->assertJsonPath(
                'message',
                'Đã gửi yêu cầu đăng ký nhà cung cấp.'
            )
            ->assertJsonPath(
                'data.application.id',
                $profile->id
            )
            ->assertJsonPath(
                'data.application.verification_status',
                'PENDING'
            )
            ->assertJsonPath(
                'data.application.business_name',
                'Dịch vụ Mới'
            );

        $this->assertDatabaseCount(
            'provider_profiles',
            1
        );

        $this->assertDatabaseHas(
            'provider_profiles',
            [
                'id' => $profile->id,
                'user_id' => $user->id,
                'business_name' =>
                    'Dịch vụ Mới',
                'experience_years' => 4,
                'verification_status' =>
                    'PENDING',
                'provider_status' => null,
                'verified_at' => null,
            ]
        );
    }
}