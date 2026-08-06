<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table): void {
            $table->id();

            $table->string('booking_code', 30)->unique();

            $table->foreignId('customer_id')
                ->constrained('users')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreignId('provider_id')
                ->constrained('users')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreignId('service_id')
                ->constrained('services')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            /*
             * Lưu lại thông tin dịch vụ tại thời điểm đặt.
             * Dữ liệu này không thay đổi nếu nhà cung cấp sửa giá sau đó.
             */
            $table->string('service_name');
            $table->decimal('unit_price', 15, 2);
            $table->unsignedInteger('quantity')->default(1);
            $table->decimal('total_amount', 15, 2);

            $table->date('booking_date');
            $table->time('booking_time');

            $table->string('customer_name');
            $table->string('customer_phone', 20);
            $table->string('service_address');
            $table->text('note')->nullable();

            $table->string('status', 30)
                ->default('PENDING')
                ->index();

            $table->text('rejection_reason')->nullable();
            $table->text('cancellation_reason')->nullable();

            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();

            $table->timestamps();

            $table->index(
                ['customer_id', 'status'],
                'bookings_customer_status_index'
            );

            $table->index(
                ['provider_id', 'status'],
                'bookings_provider_status_index'
            );

            $table->index(
                ['booking_date', 'booking_time'],
                'bookings_schedule_index'
            );
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};