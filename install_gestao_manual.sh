#!/bin/bash

# =============================================================================
# Script de Instalação Manual do Sistema de Gestão Financeira
# Autor: Claude Code
# Descrição: Instala e configura o sistema Laravel com PostgreSQL
# =============================================================================

# Variáveis de configuração
DB_USER="ieducar"
DB_PASS="ieducar"
DB_NAME="gestao_financeira"
DB_HOST="localhost"
DB_PORT="5432"
APP_NAME="Sistema de Gestão Financeira"
APP_ENV="production"
APP_DEBUG="false"
APP_URL="http://localhost"

echo "============================================================================"
echo "           SISTEMA DE GESTÃO FINANCEIRA - INSTALADOR MANUAL"
echo "============================================================================"
echo

# Função para verificar dependências
check_dependencies() {
    echo "[INFO] Verificando dependências..."
    
    # Verificar PHP
    if ! command -v php >/dev/null 2>&1; then
        echo "[ERRO] PHP não está instalado. Por favor, instale PHP 8.1+"
        exit 1
    fi
    
    # Verificar PostgreSQL
    if ! command -v psql >/dev/null 2>&1; then
        echo "[ERRO] PostgreSQL não está instalado. Por favor, instale o PostgreSQL"
        exit 1
    fi
    
    # Verificar Composer
    if ! command -v composer >/dev/null 2>&1; then
        echo "[ERRO] Composer não está instalado. Por favor, instale o Composer"
        exit 1
    fi
    
    # Verificar Node.js
    if ! command -v node >/dev/null 2>&1; then
        echo "[ERRO] Node.js não está instalado. Por favor, instale o Node.js"
        exit 1
    fi
    
    # Verificar Git
    if ! command -v git >/dev/null 2>&1; then
        echo "[ERRO] Git não está instalado. Por favor, instale o Git"
        exit 1
    fi
    
    echo "[SUCESSO] Todas as dependências estão instaladas!"
    echo
}

# Função para configurar PostgreSQL
setup_postgresql() {
    echo "[INFO] Configurando PostgreSQL..."
    
    # Verificar se o PostgreSQL está rodando
    if ! pg_isready -q; then
        echo "[AVISO] PostgreSQL não está rodando. Por favor, inicie o serviço PostgreSQL"
        echo "Execute: sudo systemctl start postgresql"
        exit 1
    fi
    
    # Verificar se o usuário PostgreSQL existe
    if ! sudo -u postgres psql -t -c "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" 2>/dev/null | grep -q 1; then
        echo "[INFO] Criando usuário PostgreSQL '$DB_USER'..."
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo "[SUCESSO] Usuário '$DB_USER' criado com sucesso!"
        else
            echo "[ERRO] Falha ao criar usuário '$DB_USER'. Verifique as permissões do PostgreSQL."
            exit 1
        fi
    else
        echo "[INFO] Usuário '$DB_USER' já existe. Atualizando senha..."
        sudo -u postgres psql -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null
        echo "[SUCESSO] Senha do usuário '$DB_USER' atualizada!"
    fi
    
    # Verificar se o banco de dados existe
    if ! sudo -u postgres psql -t -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>/dev/null | grep -q 1; then
        echo "[INFO] Criando banco de dados '$DB_NAME'..."
        sudo -u postgres createdb -O $DB_USER $DB_NAME 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo "[SUCESSO] Banco de dados '$DB_NAME' criado com sucesso!"
        else
            echo "[ERRO] Falha ao criar banco de dados '$DB_NAME'."
            exit 1
        fi
    else
        echo "[INFO] Banco de dados '$DB_NAME' já existe!"
    fi
    
    # Conceder permissões
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null
    sudo -u postgres psql -c "GRANT ALL ON SCHEMA public TO $DB_USER;" 2>/dev/null
    sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO $DB_USER;" 2>/dev/null
    sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;" 2>/dev/null
    
    echo "[SUCESSO] PostgreSQL configurado com sucesso!"
    echo
}

# Função para baixar o projeto
download_project() {
    echo "[INFO] Baixando o projeto do GitHub..."
    
    # Verificar se o diretório já existe
    if [[ -d "gestao" ]]; then
        echo "[AVISO] Diretório 'gestao' já existe. Removendo..."
        rm -rf gestao
    fi
    
    # Baixar o projeto
    git clone https://github.com/mrmendez/gestao.git
    
    if [[ $? -eq 0 ]]; then
        echo "[SUCESSO] Projeto baixado com sucesso!"
        cd gestao
    else
        echo "[ERRO] Falha ao baixar o projeto!"
        exit 1
    fi
    echo
}

# Função para configurar o ambiente Laravel
setup_laravel() {
    echo "[INFO] Configurando ambiente Laravel..."
    
    # Instalar dependências PHP
    echo "[INFO] Instalando dependências PHP..."
    composer install --no-dev --optimize-autoloader
    
    if [[ $? -ne 0 ]]; then
        echo "[ERRO] Falha ao instalar dependências PHP!"
        exit 1
    fi
    
    # Instalar dependências Node.js
    echo "[INFO] Instalando dependências Node.js..."
    npm install
    
    if [[ $? -ne 0 ]]; then
        echo "[ERRO] Falha ao instalar dependências Node.js!"
        exit 1
    fi
    
    # Compilar assets
    echo "[INFO] Compilando assets..."
    npm run build
    
    # Criar arquivo .env
    echo "[INFO] Criando arquivo .env..."
    cp .env.example .env
    
    # Gerar key da aplicação
    echo "[INFO] Gerando key da aplicação..."
    php artisan key:generate
    
    # Configurar arquivo .env
    echo "[INFO] Configurando arquivo .env..."
    
    cat > .env << EOF
APP_NAME="$APP_NAME"
APP_ENV="$APP_ENV"
APP_KEY=$(php artisan key:generate --show)
APP_DEBUG="$APP_DEBUG"
APP_URL="$APP_URL"

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=pgsql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_NAME
DB_USERNAME=$DB_USER
DB_PASSWORD=$DB_PASS

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="$APP_NAME"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

VITE_APP_NAME="${APP_NAME}"
VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
EOF
    
    echo "[SUCESSO] Ambiente Laravel configurado com sucesso!"
    echo
}

# Função para rodar migrations
run_migrations() {
    echo "[INFO] Executando migrations do banco de dados..."
    
    # Otimizar o Laravel
    php artisan optimize:clear
    
    # Rodar migrations
    php artisan migrate --force
    
    if [[ $? -eq 0 ]]; then
        echo "[SUCESSO] Migrations executadas com sucesso!"
    else
        echo "[ERRO] Falha ao executar migrations!"
        exit 1
    fi
    
    # Otimizar novamente
    php artisan optimize
    echo
}

# Função para criar usuário administrador
create_admin_user() {
    echo "[INFO] Criando usuário administrador..."
    
    # Criar usuário usando tinker
    php artisan tinker --execute="
    \$user = new App\Models\User();
    \$user->name = 'Administrador';
    \$user->email = 'admin@sistema.com';
    \$user->password = bcrypt('admin123');
    \$user->is_admin = true;
    \$user->email_verified_at = now();
    \$user->save();
    
    echo 'Usuário administrador criado com sucesso!' . PHP_EOL;
    echo 'Email: admin@sistema.com' . PHP_EOL;
    echo 'Senha: admin123' . PHP_EOL;
    "
    
    echo "[SUCESSO] Usuário administrador criado!"
    echo
}

# Função para exibir informações finais
show_final_info() {
    echo "============================================================================"
    echo "                    INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo "============================================================================"
    echo
    echo "=== INFORMAÇÕES DO SISTEMA ==="
    echo "📁 Diretório do Projeto: $(pwd)"
    echo "🗄️  Banco de Dados: PostgreSQL"
    echo "👤 Usuário do BD: $DB_USER"
    echo "🔐 Senha do BD: $DB_PASS"
    echo "🗃️  Nome do BD: $DB_NAME"
    echo
    echo "=== ACESSO AO SISTEMA ==="
    echo "🚀 Para iniciar o servidor: php artisan serve"
    echo "👤 Usuário Admin: admin@sistema.com"
    echo "🔐 Senha Admin: admin123"
    echo
    echo "=== COMANDOS ÚTEIS ==="
    echo "🔄 Reiniciar PostgreSQL: sudo systemctl restart postgresql"
    echo "📊 Acessar PostgreSQL: sudo -u postgres psql"
    echo "📝 Verificar logs: tail -f storage/logs/laravel.log"
    echo "🔧 Otimizar aplicação: php artisan optimize"
    echo "🗑️  Limpar cache: php artisan cache:clear"
    echo
    echo "=== PRÓXIMOS PASSOS ==="
    echo "1. Execute 'php artisan serve' para iniciar o servidor"
    echo "2. Acesse http://localhost:8000 no navegador"
    echo "3. Faça login com admin@sistema.com / admin123"
    echo "4. Configure o servidor web de sua preferência (Apache, Nginx, etc.)"
    echo "5. Configure SSL (HTTPS) para produção"
    echo "6. Configure backup automático do banco de dados"
    echo
    echo "🎉 Sistema instalado com sucesso! Use 'php artisan serve' para iniciar!"
    echo "============================================================================"
}

# Função principal
main() {
    # Verificar dependências
    check_dependencies
    
    # Configurar PostgreSQL
    setup_postgresql
    
    # Baixar projeto
    download_project
    
    # Configurar Laravel
    setup_laravel
    
    # Rodar migrations
    run_migrations
    
    # Criar usuário administrador
    create_admin_user
    
    # Exibir informações finais
    show_final_info
}

# Executar função principal
main "$@"