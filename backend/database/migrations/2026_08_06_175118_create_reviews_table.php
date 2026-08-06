<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table): void {
            $table->id();

            $table->foreignId('booking_id')
                ->unique()
                ->constrained('bookings')
                ->cascadeOnUpdate()
                ->cascadeOnDelete();

            $table->foreignId('customer_id')
                ->constrained('users')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreignId('provider_id')
                ->constrained('users')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->unsignedTinyInteger('rating');
            $table->text('comment')->nullable();

            $table->string('status', 20)
                ->default('VISIBLE')
                ->index();

            $table->timestamps();

            $table->index(
                ['provider_id', 'status'],
                'reviews_provider_status_index'
            );
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};