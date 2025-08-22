@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
    <div class="px-4 py-6 sm:px-0">
        <div class="max-w-md mx-auto">
            <div class="text-center mb-6">
                <h1 class="text-2xl font-bold text-gray-900">Novo Funcionário</h1>
                <p class="text-gray-600">Cadastre um novo funcionário</p>
            </div>
            
            <div class="bg-white shadow rounded-lg">
                <div class="px-4 py-5 sm:p-6">
                    <form action="{{ route('employees.store') }}" method="POST">
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
                                <label for="name" class="block text-sm font-medium text-gray-700">Nome</label>
                                <input type="text" id="name" name="name" required class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('name') }}">
                            </div>
                            
                            <div>
                                <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
                                <input type="email" id="email" name="email" required class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('email') }}">
                            </div>
                            
                            <div>
                                <label for="phone" class="block text-sm font-medium text-gray-700">Telefone</label>
                                <input type="text" id="phone" name="phone" class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('phone') }}">
                            </div>
                            
                            <div>
                                <label for="position" class="block text-sm font-medium text-gray-700">Cargo</label>
                                <input type="text" id="position" name="position" required class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('position') }}">
                            </div>
                            
                            <div>
                                <label for="salary" class="block text-sm font-medium text-gray-700">Salário</label>
                                <input type="number" id="salary" name="salary" step="0.01" class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('salary') }}">
                            </div>
                            
                            <div>
                                <label for="hire_date" class="block text-sm font-medium text-gray-700">Data de Admissão</label>
                                <input type="date" id="hire_date" name="hire_date" required class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2" value="{{ old('hire_date') ?: date('Y-m-d') }}">
                            </div>
                        </div>
                        
                        <div class="mt-6 flex items-center justify-between">
                            <a href="{{ route('employees.index') }}" class="text-sm text-gray-500 hover:text-gray-700">Cancelar</a>
                            <button type="submit" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700">
                                Salvar Funcionário
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection