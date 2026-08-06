<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->string('phone', 20)
                ->nullable()
                ->unique()
                ->after('email');

            $table->string('avatar')
                ->nullable()
                ->after('password');

            $table->string('role', 20)
                ->default('CUSTOMER')
                ->index()
                ->after('avatar');

            $table->string('status', 20)
                ->default('ACTIVE')
                ->index()
                ->after('role');

            $table->timestamp('last_login_at')
                ->nullable()
                ->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->dropUnique(['phone']);
            $table->dropIndex(['role']);
            $table->dropIndex(['status']);

            $table->dropColumn([
                'phone',
                'avatar',
                'role',
                'status',
                'last_login_at',
            ]);
        });
    }
};