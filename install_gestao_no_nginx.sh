#!/bin/bash

# =============================================================================
# Script de Instalação do Sistema de Gestão Financeira (Sem Nginx)
# Autor: Claude Code
# Descrição: Instala e configura o sistema Laravel com PostgreSQL
# =============================================================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Função para exibir mensagens
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

# Função para verificar se o comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para exibir banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║         SISTEMA DE GESTÃO FINANCEIRA - INSTALADOR           ║
║                                                              ║
║  Sistema completo para empresas de entrega com Laravel e      ║
║  PostgreSQL.                                                 ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Função para verificar dependências
check_dependencies() {
    log_info "Verificando dependências..."
    
    # Verificar PHP
    if ! command_exists php; then
        log_error "PHP não está instalado. Por favor, instale PHP 8.1+"
        exit 1
    fi
    
    # Verificar PostgreSQL
    if ! command_exists psql; then
        log_error "PostgreSQL não está instalado. Por favor, instale o PostgreSQL"
        exit 1
    fi
    
    # Verificar Composer
    if ! command_exists composer; then
        log_error "Composer não está instalado. Por favor, instale o Composer"
        exit 1
    fi
    
    # Verificar Node.js
    if ! command_exists node; then
        log_error "Node.js não está instalado. Por favor, instale o Node.js"
        exit 1
    fi
    
    # Verificar Git
    if ! command_exists git; then
        log_error "Git não está instalado. Por favor, instale o Git"
        exit 1
    fi
    
    log_success "Todas as dependências estão instaladas!"
}

# Função para configurar PostgreSQL
setup_postgresql() {
    log_info "Configurando PostgreSQL..."
    
    # Verificar se o PostgreSQL está rodando
    if ! pg_isready -q; then
        log_warning "PostgreSQL não está rodando. Por favor, inicie o serviço PostgreSQL"
        log_info "Execute: sudo systemctl start postgresql"
        exit 1
    fi
    
    # Verificar se o usuário PostgreSQL existe
    if ! sudo -u postgres psql -t -c "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" 2>/dev/null | grep -q 1; then
        log_info "Criando usuário PostgreSQL '$DB_USER'..."
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            log_success "Usuário '$DB_USER' criado com sucesso!"
        else
            log_error "Falha ao criar usuário '$DB_USER'. Verifique as permissões do PostgreSQL."
            exit 1
        fi
    else
        log_info "Usuário '$DB_USER' já existe. Atualizando senha..."
        sudo -u postgres psql -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASS';" 2>/dev/null
        log_success "Senha do usuário '$DB_USER' atualizada!"
    fi
    
    # Verificar se o banco de dados existe
    if ! sudo -u postgres psql -t -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>/dev/null | grep -q 1; then
        log_info "Criando banco de dados '$DB_NAME'..."
        sudo -u postgres createdb -O $DB_USER $DB_NAME 2>/dev/null
        if [[ $? -eq 0 ]]; then
            log_success "Banco de dados '$DB_NAME' criado com sucesso!"
        else
            log_error "Falha ao criar banco de dados '$DB_NAME'."
            exit 1
        fi
    else
        log_info "Banco de dados '$DB_NAME' já existe!"
    fi
    
    # Conceder permissões
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null
    sudo -u postgres psql -c "GRANT ALL ON SCHEMA public TO $DB_USER;" 2>/dev/null
    sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO $DB_USER;" 2>/dev/null
    sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;" 2>/dev/null
    
    log_success "PostgreSQL configurado com sucesso!"
}

# Função para baixar o projeto
download_project() {
    log_info "Baixando o projeto do GitHub..."
    
    # Verificar se o diretório já existe
    if [[ -d "gestao" ]]; then
        log_warning "Diretório 'gestao' já existe. Removendo..."
        rm -rf gestao
    fi
    
    # Baixar o projeto
    git clone https://github.com/mrmendez/gestao.git
    
    if [[ $? -eq 0 ]]; then
        log_success "Projeto baixado com sucesso!"
        cd gestao
    else
        log_error "Falha ao baixar o projeto!"
        exit 1
    fi
}

# Função para configurar o ambiente Laravel
setup_laravel() {
    log_info "Configurando ambiente Laravel..."
    
    # Instalar dependências PHP
    log_info "Instalando dependências PHP..."
    composer install --no-dev --optimize-autoloader
    
    if [[ $? -ne 0 ]]; then
        log_error "Falha ao instalar dependências PHP!"
        exit 1
    fi
    
    # Instalar dependências Node.js
    log_info "Instalando dependências Node.js..."
    npm install
    
    if [[ $? -ne 0 ]]; then
        log_error "Falha ao instalar dependências Node.js!"
        exit 1
    fi
    
    # Compilar assets
    log_info "Compilando assets..."
    npm run build
    
    # Criar arquivo .env
    log_info "Criando arquivo .env..."
    cp .env.example .env
    
    # Gerar key da aplicação
    log_info "Gerando key da aplicação..."
    php artisan key:generate
    
    # Configurar arquivo .env
    log_info "Configurando arquivo .env..."
    
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
    
    log_success "Ambiente Laravel configurado com sucesso!"
}

# Função para rodar migrations
run_migrations() {
    log_info "Executando migrations do banco de dados..."
    
    # Otimizar o Laravel
    php artisan optimize:clear
    
    # Rodar migrations
    php artisan migrate --force
    
    if [[ $? -eq 0 ]]; then
        log_success "Migrations executadas com sucesso!"
    else
        log_error "Falha ao executar migrations!"
        exit 1
    fi
    
    # Otimizar novamente
    php artisan optimize
}

# Função para criar usuário administrador
create_admin_user() {
    log_info "Criando usuário administrador..."
    
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
    
    log_success "Usuário administrador criado!"
}

# Função para exibir informações finais
show_final_info() {
    echo -e "${GREEN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║                INSTALAÇÃO CONCLUÍDA COM SUCESSO!              ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${BLUE}=== INFORMAÇÕES DO SISTEMA ===${NC}"
    echo "📁 Diretório do Projeto: $(pwd)"
    echo "🗄️  Banco de Dados: PostgreSQL"
    echo "👤 Usuário do BD: $DB_USER"
    echo "🔐 Senha do BD: $DB_PASS"
    echo "🗃️  Nome do BD: $DB_NAME"
    echo
    echo -e "${BLUE}=== ACESSO AO SISTEMA ===${NC}"
    echo "🚀 Para iniciar o servidor: php artisan serve"
    echo "👤 Usuário Admin: admin@sistema.com"
    echo "🔐 Senha Admin: admin123"
    echo
    echo -e "${BLUE}=== COMANDOS ÚTEIS ===${NC}"
    echo "🔄 Reiniciar PostgreSQL: sudo systemctl restart postgresql"
    echo "📊 Acessar PostgreSQL: sudo -u postgres psql"
    echo "📝 Verificar logs: tail -f storage/logs/laravel.log"
    echo "🔧 Otimizar aplicação: php artisan optimize"
    echo "🗑️  Limpar cache: php artisan cache:clear"
    echo
    echo -e "${YELLOW}=== PRÓXIMOS PASSOS ===${NC}"
    echo "1. Execute 'php artisan serve' para iniciar o servidor"
    echo "2. Acesse http://localhost:8000 no navegador"
    echo "3. Faça login com admin@sistema.com / admin123"
    echo "4. Configure o servidor web de sua preferência (Apache, Nginx, etc.)"
    echo "5. Configure SSL (HTTPS) para produção"
    echo "6. Configure backup automático do banco de dados"
    echo
    echo -e "${GREEN}🎉 Sistema instalado com sucesso! Use 'php artisan serve' para iniciar!${NC}"
}

# Função principal
main() {
    # Exibir banner
    show_banner
    
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

# Trap para capturar interrupções
trap 'echo -e "\n${YELLOW}Instalação interrompida pelo usuário.${NC}"; exit 1' INT

# Executar função principal
main "$@"