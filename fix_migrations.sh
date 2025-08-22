#!/bin/bash

# =============================================================================
# Script para Corrigir Migrations Pendentes
# Autor: Claude Code
# Descrição: Resolve problemas com migrations que não foram executadas
# =============================================================================

echo "============================================================================"
echo "           CORRIGINDO MIGRATIONS PENDENTES"
echo "============================================================================"
echo

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCESSO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

# 1. Verificar status atual das migrations
log_info "1. Verificando status atual das migrations..."
php artisan migrate:status
echo

# 2. Limpar cache para evitar problemas
log_info "2. Limpando cache do Laravel..."
php artisan optimize:clear
log_success "Cache limpo!"
echo

# 3. Verificar conexão com banco de dados
log_info "3. Verificando conexão com banco de dados..."
php artisan tinker --execute="echo 'Conexão com banco de dados: ' . (DB::connection()->getPdo() ? 'OK' : 'FALHA');" 2>/dev/null
if [[ $? -eq 0 ]]; then
    log_success "Conexão com banco de dados OK!"
else
    log_error "Problema na conexão com banco de dados!"
    exit 1
fi
echo

# 4. Executar migrations pendentes individualmente
log_info "4. Executando migrations pendentes individualmente..."

# Lista de migrations pendentes baseado na saída
pending_migrations=(
    "2024_01_01_000001_create_users_table"
    "2024_01_01_000003_create_financial_entries_table"
    "2024_01_01_000004_create_vehicles_table"
)

for migration in "${pending_migrations[@]}"; do
    log_info "Verificando migration: $migration"
    
    # Verificar se a migration realmente está pendente
    if php artisan migrate:status | grep -q "$migration.*Pending"; then
        log_info "Executando migration: $migration"
        
        # Tentar executar a migration individualmente
        php artisan migrate --force --path=database/migrations/$(basename "$migration".php) 2>/dev/null
        
        if [[ $? -eq 0 ]]; then
            log_success "Migration $migration executada com sucesso!"
        else
            log_warning "Migration $migration falhou. Verificando se a tabela já existe..."
            
            # Extrair nome da tabela
            table_name=$(echo "$migration" | sed 's/2024_01_01_00000[0-9]_create_//' | sed 's/_table//')
            
            if [[ -n "$table_name" ]]; then
                # Verificar se a tabela já existe
                if php artisan tinker --execute="echo \\DB::select('SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = \'$table_name\')')[0]->exists;" 2>/dev/null | grep -q "1"; then
                    log_info "Tabela '$table_name' já existe. Marcando migration como executada..."
                    
                    # Obter o próximo batch number
                    batch_number=$(php artisan tinker --execute="echo \\DB::table('migrations')->max('batch') + 1;" 2>/dev/null)
                    
                    # Inserir registro na tabela de migrations
                    php artisan tinker --execute="\\DB::table('migrations')->insert(['migration' => '$migration', 'batch' => $batch_number]);" 2>/dev/null
                    
                    if [[ $? -eq 0 ]]; then
                        log_success "Migration $migration marcada como executada!"
                    else
                        log_error "Falha ao marcar migration $migration como executada!"
                    fi
                else
                    log_error "Tabela '$table_name' não existe e migration falhou!"
                fi
            else
                log_error "Não foi possível extrair nome da tabela da migration $migration"
            fi
        fi
    else
        log_info "Migration $migration já está executada. Pulando..."
    fi
    echo
done

# 5. Verificar status final das migrations
log_info "5. Verificando status final das migrations..."
php artisan migrate:status
echo

# 6. Verificar se todas as tabelas necessárias existem
log_info "6. Verificando se todas as tabelas necessárias existem..."

required_tables=(
    "users"
    "financial_categories"
    "financial_entries"
    "vehicles"
    "vehicle_costs"
    "employees"
    "employee_payments"
    "receipts"
    "personal_access_tokens"
)

all_tables_exist=true

for table in "${required_tables[@]}"; do
    if php artisan tinker --execute="echo \\DB::select('SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = \'$table\')')[0]->exists;" 2>/dev/null | grep -q "1"; then
        log_success "Tabela '$table' existe!"
    else
        log_error "Tabela '$table' não existe!"
        all_tables_exist=false
    fi
done

echo

# 7. Criar usuário administrador se não existir
log_info "7. Verificando se existe usuário administrador..."
admin_exists=$(php artisan tinker --execute="echo \\App\\Models\\User::where('role', 'ADMIN')->exists();" 2>/dev/null)

if [[ "$admin_exists" == "1" ]]; then
    log_success "Usuário administrador já existe!"
else
    log_info "Criando usuário administrador..."
    php artisan tinker --execute="
    \$user = new App\Models\User();
    \$user->name = 'Administrador';
    \$user->email = 'admin@sistema.com';
    \$user->password = bcrypt('admin123');
    \$user->role = 'ADMIN';
    \$user->email_verified_at = now();
    \$user->save();
    echo 'Usuário administrador criado com sucesso!';
    " 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        log_success "Usuário administrador criado!"
        log_info "Email: admin@sistema.com"
        log_info "Senha: admin123"
    else
        log_error "Falha ao criar usuário administrador!"
    fi
fi

echo

# 8. Otimizar Laravel
log_info "8. Otimizando Laravel..."
php artisan optimize
log_success "Laravel otimizado!"
echo

# Resumo final
echo "============================================================================"
echo "                    CORREÇÃO DE MIGRATIONS CONCLUÍDA!"
echo "============================================================================"
echo

if [[ "$all_tables_exist" == true ]]; then
    echo -e "${GREEN}✅ Todas as tabelas necessárias existem!${NC}"
    echo -e "${GREEN}✅ Sistema pronto para uso!${NC}"
else
    echo -e "${YELLOW}⚠️  Algumas tabelas podem estar faltando${NC}"
    echo -e "${YELLOW}   Verifique o status acima e execute comandos manuais se necessário${NC}"
fi

echo
echo "=== PRÓXIMOS PASSOS ==="
echo "1. Execute 'php artisan serve' para iniciar o servidor"
echo "2. Acesse http://localhost:8000 no navegador"
echo "3. Faça login com admin@sistema.com / admin123"
echo "4. Se ainda houver problemas, verifique os logs em storage/logs/laravel.log"
echo
echo "=== COMANDOS ÚTEIS ==="
echo "• Verificar status das migrations: php artisan migrate:status"
echo "• Executar migrations pendentes: php artisan migrate"
echo "• Limpar cache: php artisan cache:clear"
echo "• Verificar tabelas: php artisan tinker (use \\DB::select('SELECT * FROM table_name'))"
echo
echo -e "${GREEN}🎉 Processo concluído! Seu sistema deve estar funcionando agora.${NC}"
echo "============================================================================"