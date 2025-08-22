<?php

namespace App\Http\Controllers;

use App\Models\Vehicle;
use App\Models\VehicleCost;
use App\Models\FinancialEntry;
use App\Models\FinancialCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class VehicleController extends Controller
{
    public function index()
    {
        $vehicles = Vehicle::with('costs')->orderBy('created_at', 'desc')->paginate(15);
        return view('vehicles.index', compact('vehicles'));
    }
    
    public function create()
    {
        return view('vehicles.create');
    }
    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'plate' => 'required|string|max:20|unique:vehicles',
            'model' => 'required|string|max:255',
            'brand' => 'required|string|max:255',
            'year' => 'nullable|integer|min:1900|max:' . date('Y'),
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        Vehicle::create($request->all());
        
        return redirect()->route('vehicles.index')
            ->with('success', 'Veículo cadastrado com sucesso!');
    }
    
    public function show(Vehicle $vehicle)
    {
        $vehicle->load('costs');
        $totalCosts = $vehicle->costs()->sum('amount');
        
        return view('vehicles.show', compact('vehicle', 'totalCosts'));
    }
    
    public function edit(Vehicle $vehicle)
    {
        return view('vehicles.edit', compact('vehicle'));
    }
    
    public function update(Request $request, Vehicle $vehicle)
    {
        $validator = Validator::make($request->all(), [
            'plate' => 'required|string|max:20|unique:vehicles,plate,' . $vehicle->id,
            'model' => 'required|string|max:255',
            'brand' => 'required|string|max:255',
            'year' => 'nullable|integer|min:1900|max:' . date('Y'),
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        $vehicle->update($request->all());
        
        return redirect()->route('vehicles.index')
            ->with('success', 'Veículo atualizado com sucesso!');
    }
    
    public function destroy(Vehicle $vehicle)
    {
        // Verificar se o veículo tem custos associados
        if ($vehicle->costs()->count() > 0) {
            return back()->with('error', 'Não é possível excluir este veículo pois existem custos associados.');
        }
        
        $vehicle->delete();
        
        return redirect()->route('vehicles.index')
            ->with('success', 'Veículo excluído com sucesso!');
    }
    
    public function createCost(Vehicle $vehicle)
    {
        return view('vehicles.create-cost', compact('vehicle'));
    }
    
    public function storeCost(Request $request, Vehicle $vehicle)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:FUEL,MAINTENANCE,TIRES,INSURANCE,TAX,OTHER',
            'description' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'date' => 'required|date',
            'odometer' => 'nullable|integer|min:0',
            'location' => 'nullable|string|max:255',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        DB::beginTransaction();
        
        try {
            // Criar o custo do veículo
            $vehicleCost = VehicleCost::create([
                'vehicle_id' => $vehicle->id,
                'type' => $request->type,
                'description' => $request->description,
                'amount' => $request->amount,
                'date' => $request->date,
                'odometer' => $request->odometer,
                'location' => $request->location,
            ]);
            
            // Criar o lançamento financeiro correspondente
            $category = FinancialCategory::firstOrCreate(
                ['name' => $this->getCategoryName($request->type), 'type' => 'EXPENSE'],
                ['description' => 'Custos de veículo']
            );
            
            FinancialEntry::create([
                'description' => $request->description,
                'amount' => $request->amount,
                'type' => 'EXPENSE',
                'date' => $request->date,
                'category_id' => $category->id,
                'vehicle_cost_id' => $vehicleCost->id,
            ]);
            
            DB::commit();
            
            return redirect()->route('vehicles.show', $vehicle)
                ->with('success', 'Custo registrado com sucesso!');
                
        } catch (\Exception $e) {
            DB::rollBack();
            
            return back()->with('error', 'Erro ao registrar custo: ' . $e->getMessage())
                ->withInput();
        }
    }
    
    public function editCost(Vehicle $vehicle, VehicleCost $cost)
    {
        return view('vehicles.edit-cost', compact('vehicle', 'cost'));
    }
    
    public function updateCost(Request $request, Vehicle $vehicle, VehicleCost $cost)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:FUEL,MAINTENANCE,TIRES,INSURANCE,TAX,OTHER',
            'description' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'date' => 'required|date',
            'odometer' => 'nullable|integer|min:0',
            'location' => 'nullable|string|max:255',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        DB::beginTransaction();
        
        try {
            // Atualizar o custo do veículo
            $cost->update($request->all());
            
            // Atualizar o lançamento financeiro correspondente
            if ($cost->financialEntry) {
                $category = FinancialCategory::firstOrCreate(
                    ['name' => $this->getCategoryName($request->type), 'type' => 'EXPENSE'],
                    ['description' => 'Custos de veículo']
                );
                
                $cost->financialEntry->update([
                    'description' => $request->description,
                    'amount' => $request->amount,
                    'date' => $request->date,
                    'category_id' => $category->id,
                ]);
            }
            
            DB::commit();
            
            return redirect()->route('vehicles.show', $vehicle)
                ->with('success', 'Custo atualizado com sucesso!');
                
        } catch (\Exception $e) {
            DB::rollBack();
            
            return back()->with('error', 'Erro ao atualizar custo: ' . $e->getMessage())
                ->withInput();
        }
    }
    
    public function destroyCost(Vehicle $vehicle, VehicleCost $cost)
    {
        DB::beginTransaction();
        
        try {
            // Excluir o lançamento financeiro correspondente
            if ($cost->financialEntry) {
                $cost->financialEntry->delete();
            }
            
            // Excluir o custo do veículo
            $cost->delete();
            
            DB::commit();
            
            return redirect()->route('vehicles.show', $vehicle)
                ->with('success', 'Custo excluído com sucesso!');
                
        } catch (\Exception $e) {
            DB::rollBack();
            
            return back()->with('error', 'Erro ao excluir custo: ' . $e->getMessage());
        }
    }
    
    private function getCategoryName($type)
    {
        return match($type) {
            'FUEL' => 'Combustível',
            'MAINTENANCE' => 'Manutenção',
            'TIRES' => 'Pneus',
            'INSURANCE' => 'Seguro',
            'TAX' => 'Imposto',
            'OTHER' => 'Outros Custos',
            default => 'Custos de Veículo',
        };
    }
}