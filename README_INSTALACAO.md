# 📋 Guia de Instalação do Sistema de Gestão Financeira

Este guia fornece instruções completas para instalar o Sistema de Gestão Financeira em seu servidor.

## 🚀 Visão Geral

O sistema é uma aplicação Laravel completa para gestão financeira de empresas de entrega, com as seguintes características:

- **Framework**: Laravel com PHP 8.1+
- **Banco de Dados**: PostgreSQL
- **Frontend**: Blade templates com Tailwind CSS
- **Assets**: Compilados com Vite e Node.js
- **Autenticação**: Sistema completo com middleware

## 📋 Pré-requisitos

### Sistema Operacional
- Ubuntu 20.04+ / Debian 10+ / CentOS 8+ / RHEL 8+

### Softwares Necessários
- **PHP**: 8.1 ou superior
- **PostgreSQL**: 12 ou superior
- **Composer**: 2.0 ou superior
- **Node.js**: 16 ou superior
- **NPM**: 8 ou superior
- **Git**: 2.0 ou superior

### Extensões PHP Necessárias
- php-cli
- php-mbstring
- php-xml
- php-bcmath
- php-curl
- php-zip
- php-pgsql

## 🔧 Instalação Automática (Recomendado)

### Opção 1: Script Completo
```bash
# Baixar o script de instalação
curl -O https://raw.githubusercontent.com/mrmendez/gestao/main/install_gestao_manual.sh

# Tornar executável
chmod +x install_gestao_manual.sh

# Executar instalação
./install_gestao_manual.sh
```

### Opção 2: Script Passo a Passo
Se preferir instalar manualmente, siga os passos abaixo:

## 🔧 Instalação Manual

### Passo 1: Instalar Dependências do Sistema

#### Para Ubuntu/Debian:
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências
sudo apt install -y \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    php-bcmath \
    php-curl \
    php-zip \
    php-pgsql \
    postgresql \
    postgresql-contrib \
    nodejs \
    npm \
    composer \
    git \
    curl \
    wget
```

#### Para CentOS/RHEL/Fedora:
```bash
# Atualizar sistema
sudo dnf update -y

# Instalar dependências
sudo dnf install -y \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    php-bcmath \
    php-curl \
    php-zip \
    php-pgsql \
    postgresql-server \
    postgresql-contrib \
    nodejs \
    npm \
    composer \
    git \
    curl \
    wget

# Inicializar PostgreSQL
sudo postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

### Passo 2: Configurar PostgreSQL

#### Iniciar o serviço PostgreSQL:
```bash
# Para sistemas systemd
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Verificar status
sudo systemctl status postgresql
```

#### Criar usuário e banco de dados:
```bash
# Acessar PostgreSQL
sudo -u postgres psql

# No prompt do PostgreSQL, execute:
CREATE USER ieducar WITH PASSWORD 'ieducar';
CREATE DATABASE gestao_financeira OWNER ieducar;
GRANT ALL PRIVILEGES ON DATABASE gestao_financeira TO ieducar;
GRANT ALL ON SCHEMA public TO ieducar;
\q
```

### Passo 3: Baixar o Projeto

```bash
# Navegar para o diretório desejado (ex: /var/www)
cd /var/www

# Baixar o projeto
sudo git clone https://github.com/mrmendez/gestao.git

# Entrar no diretório do projeto
cd gestao

# Configurar permissões
sudo chown -R $USER:$USER .
sudo chmod -R 755 storage bootstrap/cache
```

### Passo 4: Configurar Ambiente Laravel

#### Instalar dependências PHP:
```bash
composer install --no-dev --optimize-autoloader
```

#### Instalar dependências Node.js:
```bash
npm install
```

#### Compilar assets:
```bash
npm run build
```

#### Configurar arquivo .env:
```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Gerar key da aplicação
php artisan key:generate
```

#### Editar o arquivo .env:
```bash
nano .env
```

Configure as seguintes variáveis:
```env
APP_NAME="Sistema de Gestão Financeira"
APP_ENV=production
APP_DEBUG=false
APP_URL=http://seu-dominio.com

DB_CONNECTION=pgsql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=gestao_financeira
DB_USERNAME=ieducar
DB_PASSWORD=ieducar
```

### Passo 5: Executar Migrations

```bash
# Limpar cache
php artisan optimize:clear

# Executar migrations
php artisan migrate --force

# Otimizar aplicação
php artisan optimize
```

### Passo 6: Criar Usuário Administrador

```bash
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
```

## 🚀 Iniciando o Sistema

### Opção 1: Servidor Embutido (Para desenvolvimento/testes)
```bash
php artisan serve
```

Acesse: http://localhost:8000

### Opção 2: Apache (Para produção)

#### Instalar Apache:
```bash
# Ubuntu/Debian
sudo apt install apache2 libapache2-mod-php

# CentOS/RHEL
sudo dnf install httpd mod_php
```

#### Configurar Virtual Host:
```bash
# Criar arquivo de configuração
sudo nano /etc/apache2/sites-available/gestao.conf
```

Adicione o conteúdo:
```apache
<VirtualHost *:80>
    ServerName seu-dominio.com
    DocumentRoot /var/www/gestao/public

    <Directory /var/www/gestao/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/gestao_error.log
    CustomLog ${APACHE_LOG_DIR}/gestao_access.log combined
</VirtualHost>
```

#### Habilitar o site:
```bash
# Ubuntu/Debian
sudo a2ensite gestao.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# CentOS/RHEL
sudo ln -s /etc/httpd/sites-available/gestao.conf /etc/httpd/sites-enabled/
sudo systemctl restart httpd
```

### Opção 3: Nginx (Para produção)

#### Instalar Nginx e PHP-FPM:
```bash
# Ubuntu/Debian
sudo apt install nginx php-fpm

# CentOS/RHEL
sudo dnf install nginx php-fpm
```

#### Configurar Nginx:
```bash
sudo nano /etc/nginx/sites-available/gestao
```

Adicione o conteúdo:
```nginx
server {
    listen 80;
    server_name seu-dominio.com;
    root /var/www/gestao/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

#### Habilitar o site:
```bash
# Ubuntu/Debian
sudo ln -s /etc/nginx/sites-available/gestao /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# CentOS/RHEL
sudo ln -s /etc/nginx/conf.d/gestao.conf /etc/nginx/conf.d/
sudo nginx -t
sudo systemctl restart nginx
```

## 🔐 Acesso ao Sistema

Após a instalação, acesse o sistema com:

- **URL**: http://seu-dominio.com
- **Usuário**: admin@sistema.com
- **Senha**: admin123

## 🛠️ Comandos Úteis

### Manutenção do Laravel
```bash
# Limpar cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Otimizar aplicação
php artisan optimize

# Verificar status do sistema
php artisan about

# Rodar migrations
php artisan migrate

# Criar novo usuário
php artisan tinker
# No tinker:
# App\Models\User::create(['name' => 'Nome', 'email' => 'email@exemplo.com', 'password' => bcrypt('senha'), 'is_admin' => true]);
```

### Manutenção do PostgreSQL
```bash
# Reiniciar serviço
sudo systemctl restart postgresql

# Acessar PostgreSQL
sudo -u postgres psql

# Fazer backup
pg_dump -U ieducar gestao_financeira > backup.sql

# Restaurar backup
psql -U ieducar gestao_financeira < backup.sql
```

### Logs do Sistema
```bash
# Logs do Laravel
tail -f /var/www/gestao/storage/logs/laravel.log

# Logs do Apache
tail -f /var/log/apache2/gestao_error.log

# Logs do Nginx
tail -f /var/log/nginx/error.log

# Logs do PostgreSQL
sudo journalctl -u postgresql
```

## 🔧 Configuração de Produção

### Variáveis de Ambiente Importantes
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://seu-dominio.com

# Configurações de email
MAIL_MAILER=smtp
MAIL_HOST=smtp.seuprovedor.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@dominio.com
MAIL_PASSWORD=sua-senha
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@dominio.com

# Configurações de fila (opcional)
QUEUE_CONNECTION=database
```

### Segurança
```bash
# Configurar permissões corretas
sudo chown -R www-data:www-data /var/www/gestao/storage
sudo chown -R www-data:www-data /var/www/gestao/bootstrap/cache
sudo chmod -R 775 /var/www/gestao/storage
sudo chmod -R 775 /var/www/gestao/bootstrap/cache

# Configurar HTTPS (certificado SSL)
sudo apt install certbot python3-certbot-apache  # Para Apache
sudo apt install certbot python3-certbot-nginx   # Para Nginx
sudo certbot --apache -d seu-dominio.com         # Para Apache
sudo certbot --nginx -d seu-dominio.com          # Para Nginx
```

### Backup Automático
```bash
# Criar script de backup
sudo nano /usr/local/bin/backup_gestao.sh
```

Adicione o conteúdo:
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/gestao"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup do banco de dados
pg_dump -U ieducar gestao_financeira > $BACKUP_DIR/db_$DATE.sql

# Backup dos arquivos
tar -czf $BACKUP_DIR/files_$DATE.tar.gz /var/www/gestao

# Manter apenas os últimos 7 dias
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

Torne executável e agende:
```bash
sudo chmod +x /usr/local/bin/backup_gestao.sh
sudo crontab -e
```

Adicione ao crontab:
```cron
0 2 * * * /usr/local/bin/backup_gestao.sh
```

## 🚨 Solução de Problemas

### Problemas Comuns

#### 1. Erro de conexão com PostgreSQL
```bash
# Verificar se o PostgreSQL está rodando
sudo systemctl status postgresql

# Verificar se o usuário e banco existem
sudo -u postgres psql -c "\l"
sudo -u postgres psql -c "\du"

# Testar conexão
psql -h localhost -U ieducar -d gestao_financeira
```

#### 2. Erro de permissões
```bash
# Corrigir permissões do storage
sudo chown -R www-data:www-data /var/www/gestao/storage
sudo chmod -R 775 /var/www/gestao/storage
```

#### 3. Erro de cache
```bash
# Limpar todos os caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan optimize:clear
```

#### 4. Erro de dependências
```bash
# Reinstalar dependências
composer install
npm install
npm run build
```

#### 5. Erro de migrações
```bash
# Verificar status das migrations
php artisan migrate:status

# Reverter última migration
php artisan migrate:rollback

# Reexecutar migrations
php artisan migrate:fresh
```

## 📞 Suporte

Se encontrar problemas durante a instalação:

1. Verifique os logs do sistema
2. Consulte a documentação oficial do Laravel
3. Verifique os requisitos do sistema
4. Entre em contato com o suporte técnico

---

## 🎉 Parabéns!

Seu Sistema de Gestão Financeira está instalado e pronto para usar! 🚀