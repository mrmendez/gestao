<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function showLoginForm()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();
            
            return redirect()->intended('/dashboard');
        }

        return back()->withErrors([
            'email' => 'As credenciais fornecidas não correspondem aos nossos registros.',
        ])->onlyInput('email');
    }

    public function showSetupForm()
    {
        // Verificar se já existe um usuário admin
        $adminExists = User::where('role', User::ROLE_ADMIN)->exists();
        
        if ($adminExists) {
            return redirect('/login');
        }

        return view('auth.setup');
    }

    public function setup(Request $request)
    {
        // Verificar se já existe um usuário admin
        $adminExists = User::where('role', User::ROLE_ADMIN)->exists();
        
        if ($adminExists) {
            return redirect('/login')->with('error', 'Já existe um usuário administrador cadastrado.');
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => User::ROLE_ADMIN,
        ]);

        Auth::login($user);

        return redirect('/dashboard')->with('success', 'Usuário administrador criado com sucesso!');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        
        return redirect('/login');
    }

    public function checkAdmin()
    {
        $hasAdmin = User::where('role', User::ROLE_ADMIN)->exists();
        
        return response()->json([
            'hasAdmin' => $hasAdmin
        ]);
    }
}