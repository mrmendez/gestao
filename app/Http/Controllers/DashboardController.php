<?php

namespace App\Http\Controllers;

use App\Models\FinancialEntry;
use App\Models\Vehicle;
use App\Models\EmployeePayment;
use App\Models\VehicleCost;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        
        // Dados financeiros do mês atual
        $currentMonth = Carbon::now()->startOfMonth();
        $nextMonth = Carbon::now()->endOfMonth();
        
        $totalIncome = FinancialEntry::income()
            ->whereBetween('date', [$currentMonth, $nextMonth])
            ->sum('amount');
            
        $totalExpense = FinancialEntry::expense()
            ->whereBetween('date', [$currentMonth, $nextMonth])
            ->sum('amount');
            
        $netBalance = $totalIncome - $totalExpense;
        
        // Total de veículos ativos
        $totalVehicles = Vehicle::count();
        
        // Lançamentos recentes
        $recentEntries = FinancialEntry::with('category')
            ->orderBy('date', 'desc')
            ->take(10)
            ->get();
            
        // Custos por veículo no mês atual
        $vehicleCosts = VehicleCost::with('vehicle')
            ->whereBetween('date', [$currentMonth, $nextMonth])
            ->get()
            ->groupBy('vehicle_id')
            ->map(function ($costs) {
                return [
                    'vehicle' => $costs->first()->vehicle,
                    'total_cost' => $costs->sum('amount')
                ];
            })
            ->take(5);
            
        // Pagamentos de funcionários recentes
        $recentPayments = EmployeePayment::with('employee')
            ->orderBy('payment_date', 'desc')
            ->take(5)
            ->get();
            
        return view('dashboard.index', compact(
            'totalIncome',
            'totalExpense',
            'netBalance',
            'totalVehicles',
            'recentEntries',
            'vehicleCosts',
            'recentPayments'
        ));
    }
}