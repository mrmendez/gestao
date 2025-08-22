@extends('layouts.app')

@section('content')
<div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
    <div class="px-4 py-6 sm:px-0">
        <div class="max-w-md mx-auto">
            <div class="text-center mb-6">
                <h1 class="text-2xl font-bold text-gray-900">Nova Categoria</h1>
                <p class="text-gray-600">Crie uma nova categoria financeira</p>
            </div>
            
            <div class="bg-white shadow rounded-lg">
                <div class="px-4 py-5 sm:p-6">
                    <form action="{{ route('financial.store-category') }}" method="POST">
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
                                <label for="description" class="block text-sm font-medium text-gray-700">Descrição</label>
                                <textarea id="description" name="description" rows="3" class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2">{{ old('description') }}</textarea>
                            </div>
                            
                            <div>
                                <label for="type" class="block text-sm font-medium text-gray-700">Tipo</label>
                                <select id="type" name="type" required class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2">
                                    <option value="">Selecione o tipo</option>
                                    <option value="INCOME" {{ old('type') == 'INCOME' ? 'selected' : '' }}>Receita</option>
                                    <option value="EXPENSE" {{ old('type') == 'EXPENSE' ? 'selected' : '' }}>Despesa</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="mt-6 flex items-center justify-between">
                            <a href="{{ route('financial.index') }}" class="text-sm text-gray-500 hover:text-gray-700">Cancelar</a>
                            <button type="submit" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700">
                                Salvar Categoria
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection