<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EmployeePayment extends Model
{
    use HasFactory;

    protected $fillable = [
        'employee_id',
        'amount',
        'payment_date',
        'payment_method',
        'description',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'payment_date' => 'datetime',
    ];

    public function employee()
    {
        return $this->belongsTo(Employee::class, 'employee_id');
    }

    public function financialEntry()
    {
        return $this->hasOne(FinancialEntry::class, 'employee_payment_id');
    }

    public function receipts()
    {
        return $this->hasMany(Receipt::class, 'employee_payment_id');
    }

    public function scopeByEmployee($query, $employeeId)
    {
        return $query->where('employee_id', $employeeId);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('payment_date', [$startDate, $endDate]);
    }

    public function scopeByPaymentMethod($query, $method)
    {
        return $query->where('payment_method', $method);
    }

    public function getPaymentMethodLabel(): string
    {
        return match($this->payment_method) {
            'CASH' => 'Dinheiro',
            'BANK_TRANSFER' => 'Transferência Bancária',
            'CHECK' => 'Cheque',
            'PIX' => 'PIX',
            'CREDIT_CARD' => 'Cartão de Crédito',
            'DEBIT_CARD' => 'Cartão de Débito',
            default => $this->payment_method,
        };
    }
}