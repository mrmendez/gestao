<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('vehicle_costs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vehicle_id')->constrained('vehicles');
            $table->enum('type', ['FUEL', 'MAINTENANCE', 'TIRES', 'INSURANCE', 'TAX', 'OTHER']);
            $table->string('description');
            $table->decimal('amount', 10, 2);
            $table->dateTime('date');
            $table->integer('odometer')->nullable();
            $table->string('location')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vehicle_costs');
    }
};