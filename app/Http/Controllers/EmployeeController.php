<?php

namespace App\Http\Controllers;

use App\Models\Employee;
use App\Models\EmployeePayment;
use App\Models\Receipt;
use App\Models\FinancialEntry;
use App\Models\FinancialCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class EmployeeController extends Controller
{
    public function index()
    {
        $employees = Employee::with('payments')->orderBy('created_at', 'desc')->paginate(15);
        return view('employees.index', compact('employees'));
    }
    
    public function create()
    {
        return view('employees.create');
    }
    
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:employees',
            'phone' => 'nullable|string|max:20',
            'position' => 'required|string|max:255',
            'salary' => 'nullable|numeric|min:0',
            'hire_date' => 'required|date',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        Employee::create($request->all());
        
        return redirect()->route('employees.index')
            ->with('success', 'Funcionário cadastrado com sucesso!');
    }
    
    public function show(Employee $employee)
    {
        $employee->load('payments.receipts');
        $totalPayments = $employee->payments()->sum('amount');
        
        return view('employees.show', compact('employee', 'totalPayments'));
    }
    
    public function edit(Employee $employee)
    {
        return view('employees.edit', compact('employee'));
    }
    
    public function update(Request $request, Employee $employee)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:employees,email,' . $employee->id,
            'phone' => 'nullable|string|max:20',
            'position' => 'required|string|max:255',
            'salary' => 'nullable|numeric|min:0',
            'hire_date' => 'required|date',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        $employee->update($request->all());
        
        return redirect()->route('employees.index')
            ->with('success', 'Funcionário atualizado com sucesso!');
    }
    
    public function destroy(Employee $employee)
    {
        // Verificar se o funcionário tem pagamentos associados
        if ($employee->payments()->count() > 0) {
            return back()->with('error', 'Não é possível excluir este funcionário pois existem pagamentos associados.');
        }
        
        $employee->delete();
        
        return redirect()->route('employees.index')
            ->with('success', 'Funcionário excluído com sucesso!');
    }
    
    public function createPayment(Employee $employee)
    {
        return view('employees.create-payment', compact('employee'));
    }
    
    public function storePayment(Request $request, Employee $employee)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:0.01',
            'payment_date' => 'required|date',
            'payment_method' => 'required|string|max:50',
            'description' => 'nullable|string|max:255',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        DB::beginTransaction();
        
        try {
            // Criar o pagamento do funcionário
            $employeePayment = EmployeePayment::create([
                'employee_id' => $employee->id,
                'amount' => $request->amount,
                'payment_date' => $request->payment_date,
                'payment_method' => $request->payment_method,
                'description' => $request->description,
            ]);
            
            // Criar o lançamento financeiro correspondente
            $category = FinancialCategory::firstOrCreate(
                ['name' => 'Salários', 'type' => 'EXPENSE'],
                ['description' => 'Pagamentos de funcionários']
            );
            
            FinancialEntry::create([
                'description' => 'Pagamento - ' . $employee->name,
                'amount' => $request->amount,
                'type' => 'EXPENSE',
                'date' => $request->payment_date,
                'category_id' => $category->id,
                'employee_payment_id' => $employeePayment->id,
            ]);
            
            DB::commit();
            
            return redirect()->route('employees.show', $employee)
                ->with('success', 'Pagamento registrado com sucesso!');
                
        } catch (\Exception $e) {
            DB::rollBack();
            
            return back()->with('error', 'Erro ao registrar pagamento: ' . $e->getMessage())
                ->withInput();
        }
    }
    
    public function editPayment(Employee $employee, EmployeePayment $payment)
    {
        return view('employees.edit-payment', compact('employee', 'payment'));
    }
    
    public function updatePayment(Request $request, Employee $employee, EmployeePayment $payment)
    {
        $validator = Validator::make($request->all(), [
            'amount' => 'required|numeric|min:0.01',
            'payment_date' => 'required|date',
            'payment_method' => 'required|string|max:50',
            'description' => 'nullable|string|max:255',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        DB::beginTransaction();
        
        try {
            // Atualizar o pagamento do funcionário
            $payment->update($request->all());
            
            // Atualizar o lançamento financeiro correspondente
            if ($payment->financialEntry) {
                $category = FinancialCategory::firstOrCreate(
                    ['name' => 'Salários', 'type' => 'EXPENSE'],
                    ['description' => 'Pagamentos de funcionários']
                );
                
                $payment->financialEntry->update([
                    'description' => 'Pagamento - ' . $employee->name,
                    'amount' => $request->amount,
                    'date' => $request->payment_date,
                    'category_id' => $category->id,
                ]);
            }
            
            DB::commit();
            
            return redirect()->route('employees.show', $employee)
                ->with('success', 'Pagamento atualizado com sucesso!');
                
        } catch (\Exception $e) {
            DB::rollBack();
            
            return back()->with('error', 'Erro ao atualizar pagamento: ' . $e->getMessage())
                ->withInput();
        }
    }
    
    public function destroyPayment(Employee $employee, EmployeePayment $payment)
    {
        DB::beginTransaction();
        
        try {
            // Excluir os recibos associados
            $payment->receipts()->delete();
            
            // Excluir o lançamento financeiro correspondente
            if ($payment->financialEntry) {
                $payment->financialEntry->delete();
            }
            
            // Excluir o pagamento
            $payment->delete();
            
            DB::commit();
            
            return redirect()->route('employees.show', $employee)
                ->with('success', 'Pagamento excluído com sucesso!');
                
        } catch (\Exception $e) {
            DB::rollBack();
            
            return back()->with('error', 'Erro ao excluir pagamento: ' . $e->getMessage());
        }
    }
    
    public function createReceipt(Employee $employee, EmployeePayment $payment)
    {
        // Verificar se já existe recibo para este pagamento
        if ($payment->receipts()->count() > 0) {
            return back()->with('error', 'Já existe um recibo emitido para este pagamento.');
        }
        
        return view('employees.create-receipt', compact('employee', 'payment'));
    }
    
    public function storeReceipt(Request $request, Employee $employee, EmployeePayment $payment)
    {
        $validator = Validator::make($request->all(), [
            'description' => 'nullable|string|max:255',
        ]);
        
        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }
        
        try {
            // Gerar número do recibo
            $receipt = new Receipt();
            $receiptNumber = $receipt->generateReceiptNumber();
            
            // Criar o recibo
            Receipt::create([
                'employee_payment_id' => $payment->id,
                'receipt_number' => $receiptNumber,
                'amount' => $payment->amount,
                'issue_date' => now(),
                'description' => $request->description,
            ]);
            
            return redirect()->route('employees.show', $employee)
                ->with('success', 'Recibo emitido com sucesso!');
                
        } catch (\Exception $e) {
            return back()->with('error', 'Erro ao emitir recibo: ' . $e->getMessage())
                ->withInput();
        }
    }
    
    public function showReceipt(Employee $employee, EmployeePayment $payment, Receipt $receipt)
    {
        return view('employees.show-receipt', compact('employee', 'payment', 'receipt'));
    }
}