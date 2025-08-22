#!/bin/bash

# =============================================================================
# Script para Corrigir Erro 500 no Laravel
# Autor: Claude Code
# Descrição: Corrige problemas comuns que causam erro 500
# =============================================================================

echo "============================================================================"
echo "           CORRIGINDO ERRO 500 - SISTEMA DE GESTÃO FINANCEIRA"
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

# 1. Verificar e gerar APP_KEY
log_info "1. Verificando APP_KEY..."
if grep -q "base64:your-app-key-here" .env; then
    log_warning "APP_KEY não está gerado. Gerando nova chave..."
    php artisan key:generate
    if [[ $? -eq 0 ]]; then
        log_success "APP_KEY gerado com sucesso!"
    else
        log_error "Falha ao gerar APP_KEY!"
        exit 1
    fi
else
    log_success "APP_KEY já está configurado!"
fi

# 2. Limpar cache do Laravel
log_info "2. Limpando cache do Laravel..."
php artisan optimize:clear
if [[ $? -eq 0 ]]; then
    log_success "Cache limpo com sucesso!"
else
    log_error "Falha ao limpar cache!"
fi

# 3. Verificar e criar diretórios de storage
log_info "3. Verificando diretórios de storage..."
directories=(
    "storage/logs"
    "storage/framework/cache"
    "storage/framework/sessions"
    "storage/framework/views"
    "storage/app/public"
    "bootstrap/cache"
)

for dir in "${directories[@]}"; do
    if [[ ! -d "$dir" ]]; then
        log_info "Criando diretório: $dir"
        mkdir -p "$dir"
    fi
done

# 4. Configurar permissões
log_info "4. Configurando permissões..."
chmod -R 775 storage
chmod -R 775 bootstrap/cache
chmod 644 .env
log_success "Permissões configuradas!"

# 5. Verificar dependências Node.js
log_info "5. Verificando dependências Node.js..."
if [[ ! -d "node_modules" ]]; then
    log_info "Instalando dependências Node.js..."
    npm install
    if [[ $? -eq 0 ]]; then
        log_success "Dependências Node.js instaladas!"
    else
        log_error "Falha ao instalar dependências Node.js!"
    fi
else
    log_success "Dependências Node.js já estão instaladas!"
fi

# 6. Compilar assets
log_info "6. Compilando assets..."
npm run build
if [[ $? -eq 0 ]]; then
    log_success "Assets compilados com sucesso!"
else
    log_warning "Falha ao compilar assets. Tentando desenvolvimento..."
    npm run dev &
    sleep 5
    log_info "Servidor de desenvolvimento iniciado em segundo plano."
fi

# 7. Verificar conexão com banco de dados
log_info "7. Verificando conexão com banco de dados..."
php artisan tinker --execute="echo 'Conexão com banco de dados: ' . (DB::connection()->getPdo() ? 'OK' : 'FALHA');" 2>/dev/null
if [[ $? -eq 0 ]]; then
    log_success "Conexão com banco de dados OK!"
else
    log_warning "Problema na conexão com banco de dados. Verifique as configurações."
fi

# 8. Verificar status das migrations
log_info "8. Verificando status das migrations..."
php artisan migrate:status 2>/dev/null
if [[ $? -eq 0 ]]; then
    log_success "Status das migrations verificado!"
else
    log_warning "Problema ao verificar status das migrations. Tentando instalar tabela..."
    php artisan migrate:install --force
    if [[ $? -eq 0 ]]; then
        log_success "Tabela de migrations criada!"
    else
        log_error "Falha ao criar tabela de migrations!"
    fi
fi

# 9. Otimizar Laravel
log_info "9. Otimizando Laravel..."
php artisan optimize
if [[ $? -eq 0 ]]; then
    log_success "Laravel otimizado!"
else
    log_warning "Problema ao otimizar Laravel."
fi

# 10. Criar link simbólico para storage
log_info "10. Criando link simbólico para storage..."
php artisan storage:link
if [[ $? -eq 0 ]]; then
    log_success "Link simbólico criado!"
else
    log_warning "Link simbólico já existe ou não foi possível criar."
fi

# 11. Verificar se o arquivo .env está correto
log_info "11. Verificando configuração do .env..."
if ! grep -q "DB_CONNECTION=pgsql" .env; then
    log_warning "Configuração do banco de dados não está como PostgreSQL. Atualizando..."
    # Atualizar configuração do banco de dados
    sed -i 's/DB_CONNECTION=.*/DB_CONNECTION=pgsql/' .env
    sed -i 's/DB_HOST=.*/DB_HOST=localhost/' .env
    sed -i 's/DB_PORT=.*/DB_PORT=5432/' .env
    sed -i 's/DB_DATABASE=.*/DB_DATABASE=gestao_financeira/' .env
    sed -i 's/DB_USERNAME=.*/DB_USERNAME=ieducar/' .env
    sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=ieducar/' .env
    log_success "Configuração do banco de dados atualizada!"
else
    log_success "Configuração do .env está correta!"
fi

echo
echo "============================================================================"
echo "                    CORREÇÕES CONCLUÍDAS!"
echo "============================================================================"
echo
echo "=== PRÓXIMOS PASSOS ==="
echo "1. Execute 'php artisan serve' para iniciar o servidor"
echo "2. Acesse http://localhost:8000 no navegador"
echo "3. Se ainda houver erros, verifique os logs em storage/logs/laravel.log"
echo "4. Se os assets não carregarem, execute 'npm run dev' em outro terminal"
echo
echo "=== COMANDOS ÚTEIS ==="
echo "• Verificar logs: tail -f storage/logs/laravel.log"
echo "• Limpar cache: php artisan cache:clear"
echo "• Compilar assets: npm run build"
echo "• Servidor de desenvolvimento: npm run dev"
echo "• Iniciar Laravel: php artisan serve"
echo
echo -e "${GREEN}🎉 Correções concluídas! Tente iniciar o servidor agora.${NC}"
echo "============================================================================"