<?php

namespace App\Http\Controllers;

use App\Models\FinancialCategory;
use App\Models\FinancialEntry;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class FinancialController extends Controller
{
    public function index()
    {
        $categories = FinancialCategory::all();
        $entries = FinancialEntry::with('category')
            ->orderBy('date', 'desc')
            ->paginate(20);
            
        return view('financial.index', compact('categories', 'entries'));
    }
    
    public function createCategory()
    {
        return view('financial.create-category');
    }
    
    public function storeCategory(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|in:INCOME,EXPENSE',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        FinancialCategory::create($request->all());
        
        return redirect()->route('financial.index')
            ->with('success', 'Categoria criada com sucesso!');
    }
    
    public function createEntry()
    {
        $categories = FinancialCategory::all();
        return view('financial.create-entry', compact('categories'));
    }
    
    public function storeEntry(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'description' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'type' => 'required|in:INCOME,EXPENSE',
            'date' => 'required|date',
            'category_id' => 'required|exists:financial_categories,id',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        FinancialEntry::create($request->all());
        
        return redirect()->route('financial.index')
            ->with('success', 'Lançamento criado com sucesso!');
    }
    
    public function editEntry(FinancialEntry $entry)
    {
        $categories = FinancialCategory::all();
        return view('financial.edit-entry', compact('entry', 'categories'));
    }
    
    public function updateEntry(Request $request, FinancialEntry $entry)
    {
        $validator = Validator::make($request->all(), [
            'description' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'type' => 'required|in:INCOME,EXPENSE',
            'date' => 'required|date',
            'category_id' => 'required|exists:financial_categories,id',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        $entry->update($request->all());
        
        return redirect()->route('financial.index')
            ->with('success', 'Lançamento atualizado com sucesso!');
    }
    
    public function destroyEntry(FinancialEntry $entry)
    {
        $entry->delete();
        
        return redirect()->route('financial.index')
            ->with('success', 'Lançamento excluído com sucesso!');
    }
    
    public function filter(Request $request)
    {
        $query = FinancialEntry::with('category');
        
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }
        
        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }
        
        if ($request->filled('start_date') && $request->filled('end_date')) {
            $query->whereBetween('date', [
                Carbon::parse($request->start_date),
                Carbon::parse($request->end_date)
            ]);
        }
        
        if ($request->filled('search')) {
            $query->where('description', 'like', '%' . $request->search . '%');
        }
        
        $entries = $query->orderBy('date', 'desc')->paginate(20);
        $categories = FinancialCategory::all();
        
        return view('financial.index', compact('entries', 'categories'));
    }
}