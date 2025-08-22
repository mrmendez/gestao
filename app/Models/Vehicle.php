<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Vehicle extends Model
{
    use HasFactory;

    protected $fillable = [
        'plate',
        'model',
        'brand',
        'year',
    ];

    protected $casts = [
        'year' => 'integer',
    ];

    public function costs()
    {
        return $this->hasMany(VehicleCost::class, 'vehicle_id');
    }

    public function getTotalCostsAttribute()
    {
        return $this->costs()->sum('amount');
    }

    public function scopeByBrand($query, $brand)
    {
        return $query->where('brand', $brand);
    }

    public function scopeByModel($query, $model)
    {
        return $query->where('model', $model);
    }
}