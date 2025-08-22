<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VehicleCost extends Model
{
    use HasFactory;

    protected $fillable = [
        'vehicle_id',
        'type',
        'description',
        'amount',
        'date',
        'odometer',
        'location',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'date' => 'datetime',
        'odometer' => 'integer',
        'type' => 'string',
    ];

    public const TYPE_FUEL = 'FUEL';
    public const TYPE_MAINTENANCE = 'MAINTENANCE';
    public const TYPE_TIRES = 'TIRES';
    public const TYPE_INSURANCE = 'INSURANCE';
    public const TYPE_TAX = 'TAX';
    public const TYPE_OTHER = 'OTHER';

    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class, 'vehicle_id');
    }

    public function financialEntry()
    {
        return $this->hasOne(FinancialEntry::class, 'vehicle_cost_id');
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    public function scopeByVehicle($query, $vehicleId)
    {
        return $query->where('vehicle_id', $vehicleId);
    }

    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }

    public function getTypeLabel(): string
    {
        return match($this->type) {
            self::TYPE_FUEL => 'Combustível',
            self::TYPE_MAINTENANCE => 'Manutenção',
            self::TYPE_TIRES => 'Pneus',
            self::TYPE_INSURANCE => 'Seguro',
            self::TYPE_TAX => 'Imposto',
            self::TYPE_OTHER => 'Outro',
            default => 'Desconhecido',
        };
    }
}