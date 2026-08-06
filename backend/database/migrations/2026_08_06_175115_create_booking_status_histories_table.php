<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create(
            'booking_status_histories',
            function (Blueprint $table): void {
                $table->id();

                $table->foreignId('booking_id')
                    ->constrained('bookings')
                    ->cascadeOnUpdate()
                    ->cascadeOnDelete();

                $table->foreignId('changed_by')
                    ->nullable()
                    ->constrained('users')
                    ->cascadeOnUpdate()
                    ->nullOnDelete();

                $table->string('old_status', 30)->nullable();
                $table->string('new_status', 30);

                $table->text('note')->nullable();

                $table->timestamp('created_at')->useCurrent();

                $table->index(
                    ['booking_id', 'created_at'],
                    'booking_histories_booking_created_index'
                );
            }
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('booking_status_histories');
    }
};