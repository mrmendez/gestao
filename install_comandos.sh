#!/bin/bash

# =============================================================================
# Comandos de Instalação do Sistema de Gestão Financeira
# Autor: Claude Code
# Descrição: Script com comandos para instalação manual passo a passo
# =============================================================================

echo "============================================================================"
echo "           COMANDOS DE INSTALAÇÃO - SISTEMA DE GESTÃO FINANCEIRA"
echo "============================================================================"
echo

echo "Este script contém todos os comandos necessários para instalar o sistema."
echo "Execute cada comando manualmente, um por vez."
echo

echo "============================================================================"
echo "1. INSTALAR DEPENDÊNCIAS DO SISTEMA"
echo "============================================================================"
echo
echo "Para Ubuntu/Debian:"
echo "sudo apt update && sudo apt upgrade -y"
echo "sudo apt install -y php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-pgsql postgresql postgresql-contrib nodejs npm composer git curl wget"
echo
echo "Para CentOS/RHEL/Fedora:"
echo "sudo dnf update -y"
echo "sudo dnf install -y php php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-pgsql postgresql-server postgresql-contrib nodejs npm composer git curl wget"
echo "sudo postgresql-setup --initdb"
echo "sudo systemctl enable postgresql"
echo "sudo systemctl start postgresql"
echo

echo "============================================================================"
echo "2. CONFIGURAR POSTGRESQL"
echo "============================================================================"
echo
echo "Iniciar PostgreSQL:"
echo "sudo systemctl start postgresql"
echo "sudo systemctl enable postgresql"
echo "sudo systemctl status postgresql"
echo
echo "Criar usuário e banco de dados:"
echo "sudo -u postgres psql"
echo
echo "No prompt do PostgreSQL, execute:"
echo "CREATE USER ieducar WITH PASSWORD 'ieducar';"
echo "CREATE DATABASE gestao_financeira OWNER ieducar;"
echo "GRANT ALL PRIVILEGES ON DATABASE gestao_financeira TO ieducar;"
echo "GRANT ALL ON SCHEMA public TO ieducar;"
echo "\\q"
echo

echo "============================================================================"
echo "3. BAIXAR O PROJETO"
echo "============================================================================"
echo
echo "Navegar para o diretório desejado (ex: /var/www):"
echo "cd /var/www"
echo
echo "Baixar o projeto:"
echo "sudo git clone https://github.com/mrmendez/gestao.git"
echo
echo "Entrar no diretório do projeto:"
echo "cd gestao"
echo
echo "Configurar permissões:"
echo "sudo chown -R \$USER:\$USER ."
echo "sudo chmod -R 755 storage bootstrap/cache"
echo

echo "============================================================================"
echo "4. CONFIGURAR AMBIENTE LARAVEL"
echo "============================================================================"
echo
echo "Instalar dependências PHP:"
echo "composer install --no-dev --optimize-autoloader"
echo
echo "Instalar dependências Node.js:"
echo "npm install"
echo
echo "Compilar assets:"
echo "npm run build"
echo
echo "Configurar arquivo .env:"
echo "cp .env.example .env"
echo
echo "Gerar key da aplicação:"
echo "php artisan key:generate"
echo
echo "Editar o arquivo .env:"
echo "nano .env"
echo
echo "Configure as seguintes variáveis:"
echo "APP_NAME=\"Sistema de Gestão Financeira\""
echo "APP_ENV=production"
echo "APP_DEBUG=false"
echo "APP_URL=http://seu-dominio.com"
echo "DB_CONNECTION=pgsql"
echo "DB_HOST=localhost"
echo "DB_PORT=5432"
echo "DB_DATABASE=gestao_financeira"
echo "DB_USERNAME=ieducar"
echo "DB_PASSWORD=ieducar"
echo

echo "============================================================================"
echo "5. EXECUTAR MIGRATIONS"
echo "============================================================================"
echo
echo "Limpar cache:"
echo "php artisan optimize:clear"
echo
echo "Executar migrations:"
echo "php artisan migrate --force"
echo
echo "Otimizar aplicação:"
echo "php artisan optimize"
echo

echo "============================================================================"
echo "6. CRIAR USUÁRIO ADMINISTRADOR"
echo "============================================================================"
echo
echo "Criar usuário administrador:"
echo "php artisan tinker --execute=\""
echo "\\$user = new App\\Models\\User();"
echo "\\$user->name = 'Administrador';"
echo "\\$user->email = 'admin@sistema.com';"
echo "\\$user->password = bcrypt('admin123');"
echo "\\$user->is_admin = true;"
echo "\\$user->email_verified_at = now();"
echo "\\$user->save();"
echo "echo 'Usuário administrador criado com sucesso!' . PHP_EOL;"
echo "echo 'Email: admin@sistema.com' . PHP_EOL;"
echo "echo 'Senha: admin123' . PHP_EOL;"
echo "\""
echo

echo "============================================================================"
echo "7. INICIAR O SISTEMA"
echo "============================================================================"
echo
echo "Opção 1 - Servidor embutido (para desenvolvimento):"
echo "php artisan serve"
echo "Acesse: http://localhost:8000"
echo
echo "Opção 2 - Apache (para produção):"
echo "sudo apt install apache2 libapache2-mod-php"
echo "sudo nano /etc/apache2/sites-available/gestao.conf"
echo
echo "Conteúdo do arquivo:"
echo "<VirtualHost *:80>"
echo "    ServerName seu-dominio.com"
echo "    DocumentRoot /var/www/gestao/public"
echo ""
echo "    <Directory /var/www/gestao/public>"
echo "        AllowOverride All"
echo "        Require all granted"
echo "    </Directory>"
echo ""
echo "    ErrorLog \${APACHE_LOG_DIR}/gestao_error.log"
echo "    CustomLog \${APACHE_LOG_DIR}/gestao_access.log combined"
echo "</VirtualHost>"
echo ""
echo "sudo a2ensite gestao.conf"
echo "sudo a2enmod rewrite"
echo "sudo systemctl restart apache2"
echo
echo "Opção 3 - Nginx (para produção):"
echo "sudo apt install nginx php-fpm"
echo "sudo nano /etc/nginx/sites-available/gestao"
echo
echo "Conteúdo do arquivo:"
echo "server {"
echo "    listen 80;"
echo "    server_name seu-dominio.com;"
echo "    root /var/www/gestao/public;"
echo "    index index.php index.html;"
echo ""
echo "    location / {"
echo "        try_files \$uri \$uri/ /index.php?\$query_string;"
echo "    }"
echo ""
echo "    location ~ \.php$ {"
echo "        include snippets/fastcgi-php.conf;"
echo "        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;"
echo "        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;"
echo "        include fastcgi_params;"
echo "    }"
echo ""
echo "    location ~ /\.ht {"
echo "        deny all;"
echo "    }"
echo "}"
echo ""
echo "sudo ln -s /etc/nginx/sites-available/gestao /etc/nginx/sites-enabled/"
echo "sudo nginx -t"
echo "sudo systemctl restart nginx"
echo

echo "============================================================================"
echo "8. ACESSO AO SISTEMA"
echo "============================================================================"
echo
echo "URL: http://seu-dominio.com"
echo "Usuário: admin@sistema.com"
echo "Senha: admin123"
echo

echo "============================================================================"
echo "9. COMANDOS ÚTEIS"
echo "============================================================================"
echo
echo "Manutenção do Laravel:"
echo "php artisan cache:clear"
echo "php artisan config:clear"
echo "php artisan route:clear"
echo "php artisan view:clear"
echo "php artisan optimize"
echo
echo "Manutenção do PostgreSQL:"
echo "sudo systemctl restart postgresql"
echo "sudo -u postgres psql"
echo "pg_dump -U ieducar gestao_financeira > backup.sql"
echo "psql -U ieducar gestao_financeira < backup.sql"
echo
echo "Logs do sistema:"
echo "tail -f /var/www/gestao/storage/logs/laravel.log"
echo "tail -f /var/log/apache2/gestao_error.log"
echo "tail -f /var/log/nginx/error.log"
echo "sudo journalctl -u postgresql"
echo

echo "============================================================================"
echo "10. SOLUÇÃO DE PROBLEMAS COMUNS"
echo "============================================================================"
echo
echo "1. Erro de conexão com PostgreSQL:"
echo "sudo systemctl status postgresql"
echo "sudo -u postgres psql -c \"\\l\""
echo "sudo -u postgres psql -c \"\\du\""
echo "psql -h localhost -U ieducar -d gestao_financeira"
echo
echo "2. Erro de permissões:"
echo "sudo chown -R www-data:www-data /var/www/gestao/storage"
echo "sudo chmod -R 775 /var/www/gestao/storage"
echo
echo "3. Erro de cache:"
echo "php artisan cache:clear"
echo "php artisan config:clear"
echo "php artisan route:clear"
echo "php artisan view:clear"
echo "php artisan optimize:clear"
echo
echo "4. Erro de dependências:"
echo "composer install"
echo "npm install"
echo "npm run build"
echo
echo "5. Erro de migrações:"
echo "php artisan migrate:status"
echo "php artisan migrate:rollback"
echo "php artisan migrate:fresh"
echo

echo "============================================================================"
echo "                    INSTALAÇÃO CONCLUÍDA!"
echo "============================================================================"
echo
echo "Execute os comandos acima passo a passo para instalar o sistema."
echo "Em caso de dúvidas, consulte o arquivo README_INSTALACAO.md"
echo
echo "🎉 Sistema instalado com sucesso!"
echo "============================================================================"