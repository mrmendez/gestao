<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FinancialEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'description',
        'amount',
        'type',
        'date',
        'category_id',
        'vehicle_cost_id',
        'employee_payment_id',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'date' => 'datetime',
        'type' => 'string',
    ];

    public const TYPE_INCOME = 'INCOME';
    public const TYPE_EXPENSE = 'EXPENSE';

    public function category()
    {
        return $this->belongsTo(FinancialCategory::class, 'category_id');
    }

    public function vehicleCost()
    {
        return $this->belongsTo(VehicleCost::class, 'vehicle_cost_id');
    }

    public function employeePayment()
    {
        return $this->belongsTo(EmployeePayment::class, 'employee_payment_id');
    }

    public function isIncome(): bool
    {
        return $this->type === self::TYPE_INCOME;
    }

    public function isExpense(): bool
    {
        return $this->type === self::TYPE_EXPENSE;
    }

    public function scopeIncome($query)
    {
        return $query->where('type', self::TYPE_INCOME);
    }

    public function scopeExpense($query)
    {
        return $query->where('type', self::TYPE_EXPENSE);
    }

    public function scopeByCategory($query, $categoryId)
    {
        return $query->where('category_id', $categoryId);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }
}