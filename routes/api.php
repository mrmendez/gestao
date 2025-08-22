<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\FinancialController;
use App\Http\Controllers\VehicleController;
use App\Http\Controllers\EmployeeController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Rotas públicas
Route::post('/auth/check-admin', [AuthController::class, 'checkAdmin']);

// Rotas protegidas com autenticação
Route::middleware(['auth:sanctum'])->group(function () {
    // Dashboard
    Route::get('/dashboard/stats', [DashboardController::class, 'getStats']);
    
    // Gestão Financeira
    Route::prefix('financial')->group(function () {
        Route::get('/categories', [FinancialController::class, 'apiCategories']);
        Route::get('/entries', [FinancialController::class, 'apiEntries']);
        Route::post('/entries', [FinancialController::class, 'apiStoreEntry']);
        Route::put('/entries/{entry}', [FinancialController::class, 'apiUpdateEntry']);
        Route::delete('/entries/{entry}', [FinancialController::class, 'apiDestroyEntry']);
        Route::get('/summary', [FinancialController::class, 'apiSummary']);
    });
    
    // Gestão de Veículos
    Route::prefix('vehicles')->group(function () {
        Route::get('/', [VehicleController::class, 'apiIndex']);
        Route::post('/', [VehicleController::class, 'apiStore']);
        Route::get('/{vehicle}', [VehicleController::class, 'apiShow']);
        Route::put('/{vehicle}', [VehicleController::class, 'apiUpdate']);
        Route::delete('/{vehicle}', [VehicleController::class, 'apiDestroy']);
        Route::get('/{vehicle}/costs', [VehicleController::class, 'apiCosts']);
        Route::post('/{vehicle}/costs', [VehicleController::class, 'apiStoreCost']);
        Route::put('/{vehicle}/costs/{cost}', [VehicleController::class, 'apiUpdateCost']);
        Route::delete('/{vehicle}/costs/{cost}', [VehicleController::class, 'apiDestroyCost']);
    });
    
    // Gestão de Funcionários
    Route::prefix('employees')->group(function () {
        Route::get('/', [EmployeeController::class, 'apiIndex']);
        Route::post('/', [EmployeeController::class, 'apiStore']);
        Route::get('/{employee}', [EmployeeController::class, 'apiShow']);
        Route::put('/{employee}', [EmployeeController::class, 'apiUpdate']);
        Route::delete('/{employee}', [EmployeeController::class, 'apiDestroy']);
        Route::get('/{employee}/payments', [EmployeeController::class, 'apiPayments']);
        Route::post('/{employee}/payments', [EmployeeController::class, 'apiStorePayment']);
        Route::put('/{employee}/payments/{payment}', [EmployeeController::class, 'apiUpdatePayment']);
        Route::delete('/{employee}/payments/{payment}', [EmployeeController::class, 'apiDestroyPayment']);
        Route::get('/{employee}/payments/{payment}/receipts', [EmployeeController::class, 'apiReceipts']);
        Route::post('/{employee}/payments/{payment}/receipts', [EmployeeController::class, 'apiStoreReceipt']);
    });
});

// Rota de teste
Route::get('/test', function () {
    return response()->json([
        'message' => 'API está funcionando!',
        'status' => 'success'
    ]);
});