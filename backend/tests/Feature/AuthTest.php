<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_successfully(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Nguyen Van A',
            'email' => 'user@example.com',
            'phone' => '0912345678',
            'password' => 'Password123',
            'password_confirmation' => 'Password123',
            'device_name' => 'test-device',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath(
                'message',
                'Đăng ký tài khoản thành công.'
            )
            ->assertJsonPath(
                'data.user.email',
                'user@example.com'
            )
            ->assertJsonPath(
                'data.user.role',
                'CUSTOMER'
            )
            ->assertJsonPath(
                'data.user.status',
                'ACTIVE'
            )
            ->assertJsonPath(
                'data.token_type',
                'Bearer'
            );

        $this->assertDatabaseHas('users', [
            'email' => 'user@example.com',
            'phone' => '0912345678',
            'role' => 'CUSTOMER',
            'status' => 'ACTIVE',
        ]);

        $this->assertDatabaseCount(
            'personal_access_tokens',
            1
        );
    }

    public function test_registration_requires_valid_data(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => '',
            'email' => 'invalid-email',
            'phone' => '123',
            'password' => '123',
            'password_confirmation' => '456',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'name',
                'email',
                'phone',
                'password',
            ]);
    }

    public function test_registration_rejects_duplicate_email(): void
    {
        User::factory()->create([
            'email' => 'user@example.com',
        ]);

        $response = $this->postJson('/api/auth/register', [
            'name' => 'Nguyen Van B',
            'email' => 'user@example.com',
            'phone' => '0987654321',
            'password' => 'Password123',
            'password_confirmation' => 'Password123',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'email',
            ]);
    }

    public function test_registration_rejects_duplicate_phone(): void
    {
        User::factory()->create([
            'phone' => '0912345678',
        ]);

        $response = $this->postJson('/api/auth/register', [
            'name' => 'Nguyen Van B',
            'email' => 'new@example.com',
            'phone' => '0912345678',
            'password' => 'Password123',
            'password_confirmation' => 'Password123',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'phone',
            ]);
    }

    public function test_user_can_login_successfully(): void
    {
        $user = User::factory()->create([
            'email' => 'user@example.com',
            'password' => 'Password123',
            'status' => 'ACTIVE',
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'user@example.com',
            'password' => 'Password123',
            'device_name' => 'test-device',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath(
                'message',
                'Đăng nhập thành công.'
            )
            ->assertJsonPath(
                'data.user.id',
                $user->id
            )
            ->assertJsonPath(
                'data.token_type',
                'Bearer'
            );

        $this->assertNotNull(
            $user->fresh()->last_login_at
        );

        $this->assertDatabaseCount(
            'personal_access_tokens',
            1
        );
    }

    public function test_login_fails_with_wrong_password(): void
    {
        User::factory()->create([
            'email' => 'user@example.com',
            'password' => 'Password123',
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'user@example.com',
            'password' => 'WrongPassword123',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'email',
            ]);

        $this->assertDatabaseCount(
            'personal_access_tokens',
            0
        );
    }

    public function test_login_fails_for_nonexistent_email(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'notfound@example.com',
            'password' => 'Password123',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'email',
            ]);
    }

    public function test_inactive_user_cannot_login(): void
    {
        User::factory()
            ->inactive()
            ->create([
                'email' => 'locked@example.com',
                'password' => 'Password123',
            ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => 'locked@example.com',
            'password' => 'Password123',
        ]);

        $response
            ->assertForbidden()
            ->assertJsonPath('success', false)
            ->assertJsonPath(
                'message',
                'Tài khoản đang bị khóa.'
            );

        $this->assertDatabaseCount(
            'personal_access_tokens',
            0
        );
    }

    public function test_authenticated_user_can_get_profile(): void
    {
        $user = User::factory()->create();

        Sanctum::actingAs(
            $user,
            ['mobile']
        );

        $response = $this->getJson('/api/auth/me');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath(
                'data.user.id',
                $user->id
            )
            ->assertJsonPath(
                'data.user.email',
                $user->email
            );
    }

    public function test_guest_cannot_access_profile(): void
    {
        $response = $this->getJson('/api/auth/me');

        $response->assertUnauthorized();
    }

    public function test_user_can_logout_current_device(): void
    {
        $user = User::factory()->create();

        $token = $user
            ->createToken(
                'test-device',
                ['mobile']
            );

        $response = $this
            ->withHeader(
                'Authorization',
                'Bearer ' . $token->plainTextToken
            )
            ->postJson('/api/auth/logout');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath(
                'message',
                'Đăng xuất thành công.'
            );

        $this->assertDatabaseCount(
            'personal_access_tokens',
            0
        );
    }

    public function test_user_can_logout_all_devices(): void
    {
        $user = User::factory()->create();

        $firstToken = $user
            ->createToken(
                'device-one',
                ['mobile']
            );

        $user->createToken(
            'device-two',
            ['mobile']
        );

        $this->assertDatabaseCount(
            'personal_access_tokens',
            2
        );

        $response = $this
            ->withHeader(
                'Authorization',
                'Bearer ' . $firstToken->plainTextToken
            )
            ->postJson('/api/auth/logout-all');

        $response
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseCount(
            'personal_access_tokens',
            0
        );
    }
}