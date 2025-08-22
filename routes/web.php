<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\FinancialController;
use App\Http\Controllers\VehicleController;
use App\Http\Controllers\EmployeeController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Rotas públicas
Route::get('/', function () {
    return redirect('/login');
});

Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::get('/setup', [AuthController::class, 'showSetupForm'])->name('setup');
Route::post('/setup', [AuthController::class, 'setup']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Rotas protegidas
Route::middleware(['auth'])->group(function () {
    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    
    // Gestão Financeira
    Route::prefix('financial')->name('financial.')->group(function () {
        Route::get('/', [FinancialController::class, 'index'])->name('index');
        Route::get('/create-category', [FinancialController::class, 'createCategory'])->name('create-category');
        Route::post('/category', [FinancialController::class, 'storeCategory'])->name('store-category');
        Route::get('/create-entry', [FinancialController::class, 'createEntry'])->name('create-entry');
        Route::post('/entry', [FinancialController::class, 'storeEntry'])->name('store-entry');
        Route::get('/entry/{entry}/edit', [FinancialController::class, 'editEntry'])->name('edit-entry');
        Route::put('/entry/{entry}', [FinancialController::class, 'updateEntry'])->name('update-entry');
        Route::delete('/entry/{entry}', [FinancialController::class, 'destroyEntry'])->name('destroy-entry');
        Route::post('/filter', [FinancialController::class, 'filter'])->name('filter');
    });
    
    // Gestão de Veículos
    Route::prefix('vehicles')->name('vehicles.')->group(function () {
        Route::get('/', [VehicleController::class, 'index'])->name('index');
        Route::get('/create', [VehicleController::class, 'create'])->name('create');
        Route::post('/', [VehicleController::class, 'store'])->name('store');
        Route::get('/{vehicle}', [VehicleController::class, 'show'])->name('show');
        Route::get('/{vehicle}/edit', [VehicleController::class, 'edit'])->name('edit');
        Route::put('/{vehicle}', [VehicleController::class, 'update'])->name('update');
        Route::delete('/{vehicle}', [VehicleController::class, 'destroy'])->name('destroy');
        
        // Custos de veículos
        Route::get('/{vehicle}/create-cost', [VehicleController::class, 'createCost'])->name('create-cost');
        Route::post('/{vehicle}/cost', [VehicleController::class, 'storeCost'])->name('store-cost');
        Route::get('/{vehicle}/cost/{cost}/edit', [VehicleController::class, 'editCost'])->name('edit-cost');
        Route::put('/{vehicle}/cost/{cost}', [VehicleController::class, 'updateCost'])->name('update-cost');
        Route::delete('/{vehicle}/cost/{cost}', [VehicleController::class, 'destroyCost'])->name('destroy-cost');
    });
    
    // Gestão de Funcionários
    Route::prefix('employees')->name('employees.')->group(function () {
        Route::get('/', [EmployeeController::class, 'index'])->name('index');
        Route::get('/create', [EmployeeController::class, 'create'])->name('create');
        Route::post('/', [EmployeeController::class, 'store'])->name('store');
        Route::get('/{employee}', [EmployeeController::class, 'show'])->name('show');
        Route::get('/{employee}/edit', [EmployeeController::class, 'edit'])->name('edit');
        Route::put('/{employee}', [EmployeeController::class, 'update'])->name('update');
        Route::delete('/{employee}', [EmployeeController::class, 'destroy'])->name('destroy');
        
        // Pagamentos de funcionários
        Route::get('/{employee}/create-payment', [EmployeeController::class, 'createPayment'])->name('create-payment');
        Route::post('/{employee}/payment', [EmployeeController::class, 'storePayment'])->name('store-payment');
        Route::get('/{employee}/payment/{payment}/edit', [EmployeeController::class, 'editPayment'])->name('edit-payment');
        Route::put('/{employee}/payment/{payment}', [EmployeeController::class, 'updatePayment'])->name('update-payment');
        Route::delete('/{employee}/payment/{payment}', [EmployeeController::class, 'destroyPayment'])->name('destroy-payment');
        
        // Recibos
        Route::get('/{employee}/payment/{payment}/create-receipt', [EmployeeController::class, 'createReceipt'])->name('create-receipt');
        Route::post('/{employee}/payment/{payment}/receipt', [EmployeeController::class, 'storeReceipt'])->name('store-receipt');
        Route::get('/{employee}/payment/{payment}/receipt/{receipt}', [EmployeeController::class, 'showReceipt'])->name('show-receipt');
    });
});

// Rotas API
Route::prefix('api')->name('api.')->group(function () {
    // API de autenticação
    Route::get('/auth/check-admin', [AuthController::class, 'checkAdmin'])->name('auth.check-admin');
    
    // API protegida
    Route::middleware(['auth'])->group(function () {
        // API de Dashboard
        Route::get('/dashboard/stats', [DashboardController::class, 'getStats'])->name('dashboard.stats');
        
        // API de Gestão Financeira
        Route::prefix('financial')->name('financial.')->group(function () {
            Route::get('/categories', [FinancialController::class, 'apiCategories'])->name('api-categories');
            Route::get('/entries', [FinancialController::class, 'apiEntries'])->name('api-entries');
            Route::get('/summary', [FinancialController::class, 'apiSummary'])->name('api-summary');
        });
        
        // API de Veículos
        Route::prefix('vehicles')->name('vehicles.')->group(function () {
            Route::get('/', [VehicleController::class, 'apiIndex'])->name('api-index');
            Route::get('/{vehicle}', [VehicleController::class, 'apiShow'])->name('api-show');
            Route::get('/{vehicle}/costs', [VehicleController::class, 'apiCosts'])->name('api-costs');
        });
        
        // API de Funcionários
        Route::prefix('employees')->name('employees.')->group(function () {
            Route::get('/', [EmployeeController::class, 'apiIndex'])->name('api-index');
            Route::get('/{employee}', [EmployeeController::class, 'apiShow'])->name('api-show');
            Route::get('/{employee}/payments', [EmployeeController::class, 'apiPayments'])->name('api-payments');
        });
    });
});