@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
    <div class="px-4 py-6 sm:px-0">
        <div class="max-w-md mx-auto">
            <div class="text-center mb-6">
                <h1 class="text-2xl font-bold text-gray-900">Novo Veículo</h1>
                <p class="text-gray-600">Cadastre um novo veículo na frota</p>
            </div>
            
            <div class="bg-white shadow rounded-lg">
                <div class="px-4 py-5 sm:p-6">
                    <form action="{{ route('vehicles.store') }}" method="POST">
                        @csrf
                        
                        @if ($errors->any())
                            <div class="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded mb-4">
                                @foreach ($errors->all() as $error)
                                    <p>{{ $error }}</p>
                                @endforeach
                            </div>
                        @endif
                        
                        <div class="space-y-4">
                            <div>
                                <label for="plate" class="block text-sm font-medium text-gray-700">Placa</label>
                                <input type="text" id="plate" name="plate" required class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('plate') }}" placeholder="ABC-1234">
                            </div>
                            
                            <div>
                                <label for="brand" class="block text-sm font-medium text-gray-700">Marca</label>
                                <input type="text" id="brand" name="brand" required class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('brand') }}" placeholder="Volkswagen">
                            </div>
                            
                            <div>
                                <label for="model" class="block text-sm font-medium text-gray-700">Modelo</label>
                                <input type="text" id="model" name="model" required class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('model') }}" placeholder="Saveiro">
                            </div>
                            
                            <div>
                                <label for="year" class="block text-sm font-medium text-gray-700">Ano</label>
                                <input type="number" id="year" name="year" min="1900" max="{{ date('Y') }}" class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('year') }}" placeholder="2024">
                            </div>
                        </div>
                        
                        <div class="mt-6 flex items-center justify-between">
                            <a href="{{ route('vehicles.index') }}" class="text-sm text-gray-500 hover:text-gray-700">Cancelar</a>
                            <button type="submit" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700">
                                Salvar Veículo
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection