<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Receipt extends Model
{
    use HasFactory;

    protected $fillable = [
        'employee_payment_id',
        'receipt_number',
        'amount',
        'issue_date',
        'description',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'issue_date' => 'datetime',
    ];

    public function employeePayment()
    {
        return $this->belongsTo(EmployeePayment::class, 'employee_payment_id');
    }

    public function scopeByReceiptNumber($query, $receiptNumber)
    {
        return $query->where('receipt_number', $receiptNumber);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('issue_date', [$startDate, $endDate]);
    }

    public function generateReceiptNumber(): string
    {
        $prefix = 'REC';
        $year = date('Y');
        $month = date('m');
        $lastReceipt = self::whereYear('issue_date', $year)
            ->whereMonth('issue_date', $month)
            ->orderBy('receipt_number', 'desc')
            ->first();

        if ($lastReceipt) {
            $lastNumber = intval(substr($lastReceipt->receipt_number, -4));
            $newNumber = str_pad($lastNumber + 1, 4, '0', STR_PAD_LEFT);
        } else {
            $newNumber = '0001';
        }

        return "{$prefix}{$year}{$month}{$newNumber}";
    }
}