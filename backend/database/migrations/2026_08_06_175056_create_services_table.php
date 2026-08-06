<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('services', function (Blueprint $table): void {
            $table->id();

            $table->foreignId('category_id')
                ->constrained('service_categories')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->foreignId('provider_id')
                ->constrained('users')
                ->cascadeOnUpdate()
                ->restrictOnDelete();

            $table->string('name');
            $table->string('slug');
            $table->text('description')->nullable();

            $table->decimal('price', 15, 2);
            $table->string('price_unit', 50)->default('lần');

            $table->unsignedInteger('estimated_duration_minutes')
                ->nullable();

            $table->string('image')->nullable();

            $table->string('status', 20)
                ->default('ACTIVE')
                ->index();

            $table->timestamps();
            $table->softDeletes();

            $table->unique(
                ['provider_id', 'slug'],
                'services_provider_slug_unique'
            );

            $table->index(
                ['category_id', 'status'],
                'services_category_status_index'
            );
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('services');
    }
};