# Solução para Migrations Pendentes

## 🚨 Problema Identificado

Baseado na saída do script, as seguintes migrations estão pendentes:

- `2024_01_01_000001_create_users_table` (Pendente)
- `2024_01_01_000003_create_financial_entries_table` (Pendente)
- `2024_01_01_000004_create_vehicles_table` (Pendente)

## 🛠️ Solução Imediata

### Opção 1: Executar Script Automático (Recomendado)

```bash
cd gestao
./fix_migrations.sh
```

Este script irá:
- ✅ Verificar o status atual das migrations
- ✅ Executar cada migration pendente individualmente
- ✅ Verificar se as tabelas já existem no banco de dados
- ✅ Marcar migrations como executadas quando as tabelas existem
- ✅ Criar usuário administrador se não existir
- ✅ Verificar se todas as tabelas necessárias existem

### Opção 2: Solução Manual Passo a Passo

#### 1. Verificar Status Atual
```bash
php artisan migrate:status
```

#### 2. Limpar Cache
```bash
php artisan optimize:clear
```

#### 3. Executar Migrations Pendentes Individualmente

```bash
# Executar migration de users
php artisan migrate --force --path=database/migrations/2024_01_01_000001_create_users_table.php

# Executar migration de financial_entries
php artisan migrate --force --path=database/migrations/2024_01_01_000003_create_financial_entries_table.php

# Executar migration de vehicles
php artisan migrate --force --path=database/migrations/2024_01_01_000004_create_vehicles_table.php
```

#### 4. Se Alguma Migration Falhar (Tabela já existe)

Se receber erro de tabela duplicada, marque a migration como executada manualmente:

```bash
# Para tabela users
php artisan tinker --execute="
\\DB::table('migrations')->insert([
    'migration' => '2024_01_01_000001_create_users_table',
    'batch' => \\DB::table('migrations')->max('batch') + 1
]);
"

# Para tabela financial_entries
php artisan tinker --execute="
\\DB::table('migrations')->insert([
    'migration' => '2024_01_01_000003_create_financial_entries_table',
    'batch' => \\DB::table('migrations')->max('batch') + 1
]);
"

# Para tabela vehicles
php artisan tinker --execute="
\\DB::table('migrations')->insert([
    'migration' => '2024_01_01_000004_create_vehicles_table',
    'batch' => \\DB::table('migrations')->max('batch') + 1
]);
"
```

#### 5. Verificar Status Final
```bash
php artisan migrate:status
```

#### 6. Criar Usuário Administrador (se não existir)
```bash
php artisan tinker --execute="
\$user = new App\Models\User();
\$user->name = 'Administrador';
\$user->email = 'admin@sistema.com';
\$user->password = bcrypt('admin123');
\$user->role = 'ADMIN';
\$user->email_verified_at = now();
\$user->save();
echo 'Usuário administrador criado com sucesso!';
"
```

## 🔍 Verificação de Tabelas

Após executar as migrations, verifique se todas as tabelas necessárias existem:

```bash
php artisan tinker --execute="
echo 'Tabelas no banco de dados:' . PHP_EOL;
\$tables = \\DB::select('SELECT tablename FROM pg_tables WHERE schemaname = \'public\'');
foreach (\$tables as \$table) {
    echo '- ' . \$table->tablename . PHP_EOL;
}
"
```

Tabelas necessárias:
- ✅ `users` (para autenticação)
- ✅ `financial_categories` (para categorias financeiras)
- ✅ `financial_entries` (para lançamentos financeiros)
- ✅ `vehicles` (para veículos)
- ✅ `vehicle_costs` (para custos de veículos)
- ✅ `employees` (para funcionários)
- ✅ `employee_payments` (para pagamentos de funcionários)
- ✅ `receipts` (para recibos)
- ✅ `personal_access_tokens` (para tokens de API)

## 🚀 Iniciar a Aplicação

Após resolver as migrations:

```bash
# Iniciar servidor Laravel
php artisan serve

# Iniciar servidor de assets (em outro terminal)
npm run dev
```

Acesse: http://localhost:8000

## 📋 Login

- **Email**: `admin@sistema.com`
- **Senha**: `admin123`

## 🆘 Se o Problema Persistir

1. **Verifique os logs**: `tail -f storage/logs/laravel.log`
2. **Teste a conexão**: `php artisan tinker --execute="echo DB::connection()->getPdo() ? 'Conexão OK' : 'Conexão FALHA';"`
3. **Verifique o PostgreSQL**: `sudo systemctl status postgresql`
4. **Reinicie o serviço**: `sudo systemctl restart postgresql`

## 📝 Resumo do Problema

O problema ocorreu porque algumas migrations não foram executadas completamente durante o processo de instalação. Isso pode acontecer por vários motivos:

- Timeouts durante a execução
- Conflitos com tabelas existentes
- Problemas de permissão no banco de dados
- Cache corrompido do Laravel

A solução garante que todas as tabelas necessárias sejam criadas e que o sistema tenha um estado consistente para funcionar corretamente.

---

**Importante**: Após executar os comandos acima, seu sistema deve estar completamente funcional e pronto para uso!