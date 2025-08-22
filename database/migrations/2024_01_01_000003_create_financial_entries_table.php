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
        Schema::create('financial_entries', function (Blueprint $table) {
            $table->id();
            $table->string('description');
            $table->decimal('amount', 10, 2);
            $table->enum('type', ['INCOME', 'EXPENSE']);
            $table->dateTime('date');
            $table->foreignId('category_id')->constrained('financial_categories');
            $table->foreignId('vehicle_cost_id')->nullable()->unique()->constrained('vehicle_costs');
            $table->foreignId('employee_payment_id')->nullable()->unique()->constrained('employee_payments');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('financial_entries');
    }
};