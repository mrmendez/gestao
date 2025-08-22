#!/bin/bash

# =============================================================================
# Script de Instalação do Sistema de Gestão Financeira
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

# Função para verificar se o usuário tem permissões de root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script precisa ser executado como root (sudo)."
        exit 1
    fi
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

# Função para exibir informações do sistema
show_system_info() {
    log_info "Informações do Sistema:"
    echo "  Sistema Operacional: $(uname -s)"
    echo "  Versão do Kernel: $(uname -r)"
    echo "  Arquitetura: $(uname -m)"
    echo "  Usuário Atual: $(whoami)"
    echo "  Data/Hora: $(date)"
    echo
}

# Função para verificar dependências
check_dependencies() {
    log_info "Verificando dependências..."
    
    local missing_deps=()
    
    # Verificar comandos essenciais
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi
    
    if ! command_exists wget; then
        missing_deps+=("wget")
    fi
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    # Verificar PHP
    if ! command_exists php; then
        missing_deps+=("php")
    else
        local php_version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;")
        log_info "Versão do PHP: $php_version"
        
        if [[ $(echo "$php_version < 8.1" | bc -l) -eq 1 ]]; then
            log_warning "PHP 8.1+ é recomendado. Versão atual: $php_version"
        fi
    fi
    
    # Verificar PostgreSQL
    if ! command_exists psql; then
        missing_deps+=("postgresql")
    fi
    
    # Verificar Composer
    if ! command_exists composer; then
        missing_deps+=("composer")
    fi
    
    # Verificar Node.js
    if ! command_exists node; then
        missing_deps+=("nodejs")
    else
        local node_version=$(node --version)
        log_info "Versão do Node.js: $node_version"
    fi
    
    # Verificar NPM
    if ! command_exists npm; then
        missing_deps+=("npm")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Dependências faltando: ${missing_deps[*]}"
        echo
        log_info "Instalando dependências..."
        
        # Detectar o sistema operacional
        if [[ -f /etc/debian_version ]]; then
            # Debian/Ubuntu
            apt update
            apt install -y curl wget git php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-pgsql postgresql postgresql-contrib nodejs npm composer
        elif [[ -f /etc/redhat-release ]]; then
            # CentOS/RHEL/Fedora
            if command_exists dnf; then
                dnf install -y curl wget git php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-pgsql postgresql-server postgresql-contrib nodejs npm composer
                # Inicializar PostgreSQL
                postgresql-setup --initdb
                systemctl enable postgresql
                systemctl start postgresql
            else
                yum install -y curl wget git php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-pgsql postgresql-server postgresql-contrib nodejs npm composer
                # Inicializar PostgreSQL
                postgresql-setup initdb
                systemctl enable postgresql
                systemctl start postgresql
            fi
        else
            log_error "Sistema operacional não suportado automaticamente."
            log_info "Por favor, instale manualmente as dependências: ${missing_deps[*]}"
            exit 1
        fi
        
        log_success "Dependências instaladas com sucesso!"
    else
        log_success "Todas as dependências estão instaladas!"
    fi
    
    echo
}

# Função para configurar PostgreSQL
setup_postgresql() {
    log_info "Configurando PostgreSQL..."
    
    # Verificar se o PostgreSQL está rodando
    if ! systemctl is-active --quiet postgresql; then
        log_warning "PostgreSQL não está rodando. Iniciando serviço..."
        systemctl start postgresql
        systemctl enable postgresql
        sleep 3
    fi
    
    # Verificar se o usuário PostgreSQL existe
    if ! sudo -u postgres psql -t -c "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1; then
        log_info "Criando usuário PostgreSQL '$DB_USER'..."
        sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
        log_success "Usuário '$DB_USER' criado com sucesso!"
    else
        log_info "Usuário '$DB_USER' já existe. Atualizando senha..."
        sudo -u postgres psql -c "ALTER USER $DB_USER WITH PASSWORD '$DB_PASS';"
        log_success "Senha do usuário '$DB_USER' atualizada!"
    fi
    
    # Verificar se o banco de dados existe
    if ! sudo -u postgres psql -t -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1; then
        log_info "Criando banco de dados '$DB_NAME'..."
        sudo -u postgres createdb -O $DB_USER $DB_NAME
        log_success "Banco de dados '$DB_NAME' criado com sucesso!"
    else
        log_info "Banco de dados '$DB_NAME' já existe!"
    fi
    
    # Conceder permissões
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    sudo -u postgres psql -c "GRANT ALL ON SCHEMA public TO $DB_USER;"
    sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO $DB_USER;"
    sudo -u postgres psql -d $DB_NAME -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;"
    
    log_success "PostgreSQL configurado com sucesso!"
    echo
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
    
    echo
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
    echo
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
    
    echo
}

# Função para configurar permissões
setup_permissions() {
    log_info "Configurando permissões..."
    
    # Configurar permissões do storage
    chown -R www-data:www-data storage bootstrap/cache
    chmod -R 775 storage bootstrap/cache
    
    # Configurar permissões dos arquivos
    chmod -R 644 .
    chmod -R 755 storage bootstrap/cache
    
    log_success "Permissões configuradas com sucesso!"
    echo
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
    echo
}

# Função para configurar servidor web
setup_web_server() {
    log_info "Configurando servidor web..."
    
    # Verificar qual servidor web está disponível
    if command_exists apache2; then
        log_info "Configurando Apache2..."
        
        # Criar virtual host
        cat > /etc/apache2/sites-available/gestao.conf << EOF
<VirtualHost *:80>
    ServerName gestao.local
    DocumentRoot /var/www/gestao/public

    <Directory /var/www/gestao/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/gestao_error.log
    CustomLog \${APACHE_LOG_DIR}/gestao_access.log combined
</VirtualHost>
EOF
        
        # Habilitar site e módulos
        a2ensite gestao.conf
        a2enmod rewrite
        
        # Reiniciar Apache
        systemctl restart apache2
        
        log_success "Apache2 configurado!"
        
    elif command_exists nginx; then
        log_info "Configurando Nginx..."
        
        # Criar configuração do Nginx
        cat > /etc/nginx/sites-available/gestao << EOF
server {
    listen 80;
    server_name gestao.local;
    root /var/www/gestao/public;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
        
        # Habilitar site
        ln -s /etc/nginx/sites-available/gestao /etc/nginx/sites-enabled/
        
        # Testar configuração e reiniciar Nginx
        nginx -t && systemctl restart nginx
        
        log_success "Nginx configurado!"
        
    else
        log_warning "Nenhum servidor web (Apache/Nginx) encontrado."
        log_info "Você pode usar 'php artisan serve' para iniciar o servidor embutido."
    fi
    
    echo
}

# Função para mover projeto para diretório web
move_to_web_directory() {
    log_info "Movendo projeto para diretório web..."
    
    # Mover para /var/www
    mv gestao /var/www/
    cd /var/www/gestao
    
    # Configurar permissões novamente
    chown -R www-data:www-data /var/www/gestao
    chmod -R 775 /var/www/gestao/storage /var/www/gestao/bootstrap/cache
    
    log_success "Projeto movido para /var/www/gestao!"
    echo
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
    echo "📁 Diretório do Projeto: /var/www/gestao"
    echo "🗄️  Banco de Dados: PostgreSQL"
    echo "👤 Usuário do BD: $DB_USER"
    echo "🔐 Senha do BD: $DB_PASS"
    echo "🗃️  Nome do BD: $DB_NAME"
    echo
    echo -e "${BLUE}=== ACESSO AO SISTEMA ===${NC}"
    echo "🌐 URL: http://gestao.local"
    echo "👤 Usuário Admin: admin@sistema.com"
    echo "🔐 Senha Admin: admin123"
    echo
    echo -e "${BLUE}=== COMANDOS ÚTEIS ===${NC}"
    echo "📋 Verificar status do serviço: systemctl status postgresql"
    echo "🔄 Reiniciar serviço: systemctl restart postgresql"
    echo "📊 Acessar PostgreSQL: sudo -u postgres psql"
    echo "🚀 Iniciar servidor embutido: cd /var/www/gestao && php artisan serve"
    echo "📝 Verificar logs: tail -f /var/www/gestao/storage/logs/laravel.log"
    echo
    echo -e "${YELLOW}=== PRÓXIMOS PASSOS ===${NC}"
    echo "1. Adicione 'gestao.local' ao seu arquivo /etc/hosts"
    echo "2. Configure o domínio real no arquivo .env"
    echo "3. Configure SSL (HTTPS) para produção"
    echo "4. Configure backup automático do banco de dados"
    echo "5. Configure monitoramento do sistema"
    echo
    echo -e "${GREEN}🎉 Sistema instalado com sucesso! Acesse http://gestao.local para começar!${NC}"
}

# Função principal
main() {
    # Exibir banner
    show_banner
    
    # Exibir informações do sistema
    show_system_info
    
    # Verificar permissões de root
    check_root
    
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
    
    # Configurar permissões
    setup_permissions
    
    # Criar usuário administrador
    create_admin_user
    
    # Mover para diretório web
    move_to_web_directory
    
    # Configurar servidor web
    setup_web_server
    
    # Exibir informações finais
    show_final_info
}

# Trap para capturar interrupções
trap 'echo -e "\n${YELLOW}Instalação interrompida pelo usuário.${NC}"; exit 1' INT

# Executar função principal
main "$@"