<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table(
            'provider_profiles',
            function (Blueprint $table): void {
                $table->string(
                    'provider_status',
                    20
                )
                    ->nullable()
                    ->after('verification_status')
                    ->index();
            }
        );

        /*
         * Backfill dữ liệu cũ:
         *
         * Provider đã APPROVED trước migration
         * được xem là đang hoạt động.
         *
         * PENDING / REJECTED vẫn để NULL.
         */
        DB::table('provider_profiles')
            ->where(
                'verification_status',
                'APPROVED'
            )
            ->update([
                'provider_status' => 'ACTIVE',
            ]);
    }

    public function down(): void
    {
        Schema::table(
            'provider_profiles',
            function (Blueprint $table): void {
                $table->dropIndex([
                    'provider_status',
                ]);

                $table->dropColumn(
                    'provider_status'
                );
            }
        );
    }
};