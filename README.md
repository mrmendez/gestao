# Sistema de Gestão Financeira - Laravel & PostgreSQL

Um sistema completo de gestão financeira para empresas de entrega, desenvolvido com Laravel 10 e PostgreSQL.

## 🚀 Funcionalidades

### ✅ Funcionalidades Implementadas

#### 📊 Dashboard
- Visão geral financeira com receitas, despesas e saldo líquido
- Lançamentos financeiros recentes
- Custos por veículo
- Pagamentos de funcionários recentes

#### 💰 Gestão Financeira
- Cadastro de categorias financeiras (receitas/despesas)
- Lançamentos financeiros com filtros
- Integração automática com custos de veículos e pagamentos de funcionários
- Relatórios e sumários

#### 🚗 Gestão de Veículos
- Cadastro de veículos com placa, marca, modelo e ano
- Registro de custos (combustível, manutenção, pneus, seguro, impostos, outros)
- Integração automática com o sistema financeiro
- Histórico de custos por veículo

#### 👥 Gestão de Funcionários
- Cadastro de funcionários com informações completas
- Controle de pagamentos com múltiplos métodos
- Emissão de recibos automáticos
- Integração automática com o sistema financeiro

#### 🔐 Sistema de Autenticação
- Login seguro com sessão
- Setup inicial para primeiro administrador
- Proteção de rotas com middleware
- Controle de acesso por roles (ADMIN/USER)

#### 🌐 API REST
- API completa para integração com frontend
- Endpoints para todas as funcionalidades
- Autenticação via tokens
- Respostas em JSON

## 🛠️ Tecnologias Utilizadas

### Backend
- **PHP 8.1+**
- **Laravel 10** - Framework principal
- **PostgreSQL** - Banco de dados
- **Eloquent ORM** - Mapeamento objeto-relacional
- **Laravel Sanctum** - Autenticação API
- **Laravel Vite** - Build tool

### Frontend
- **Blade Templates** - Template engine
- **Tailwind CSS** - Framework CSS
- **Alpine.js** - Framework JavaScript leve
- **Axios** - Cliente HTTP
- **Vite** - Build tool e desenvolvimento

### Infraestrutura
- **Migrations** - Controle de versão do banco de dados
- **Models Eloquent** - Modelo de dados
- **Controllers** - Lógica de negócio
- **Middleware** - Interceptação de requisições
- **Routes** - Definição de rotas

## 📦 Estrutura do Projeto

```
laravel-financial-system/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php
│   │   │   ├── DashboardController.php
│   │   │   ├── FinancialController.php
│   │   │   ├── VehicleController.php
│   │   │   └── EmployeeController.php
│   │   └── Middleware/
│   ├── Models/
│   │   ├── User.php
│   │   ├── FinancialCategory.php
│   │   ├── FinancialEntry.php
│   │   ├── Vehicle.php
│   │   ├── VehicleCost.php
│   │   ├── Employee.php
│   │   ├── EmployeePayment.php
│   │   └── Receipt.php
├── database/
│   └── migrations/
├── resources/
│   ├── views/
│   │   ├── layouts/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── financial/
│   │   ├── vehicles/
│   │   └── employees/
│   ├── css/
│   └── js/
├── routes/
│   ├── web.php
│   └── api.php
├── .env
├── composer.json
├── package.json
└── vite.config.js
```

## 🚀 Instalação

### Pré-requisitos
- PHP 8.1+
- Composer
- Node.js 16+
- PostgreSQL 12+

### Passo a Passo

1. **Clone o repositório**
   ```bash
   git clone <repository-url>
   cd laravel-financial-system
   ```

2. **Instale as dependências PHP**
   ```bash
   composer install
   ```

3. **Instale as dependências Node.js**
   ```bash
   npm install
   ```

4. **Configure o ambiente**
   ```bash
   cp .env.example .env
   ```
   
   Edite o arquivo `.env` com suas credenciais do PostgreSQL:
   ```env
   DB_CONNECTION=pgsql
   DB_HOST=127.0.0.1
   DB_PORT=5432
   DB_DATABASE=financial_system
   DB_USERNAME=postgres
   DB_PASSWORD=your_password
   ```

5. **Gere a chave da aplicação**
   ```bash
   php artisan key:generate
   ```

6. **Execute as migrations**
   ```bash
   php artisan migrate
   ```

7. **Compile os assets**
   ```bash
   npm run build
   ```

8. **Inicie o servidor de desenvolvimento**
   ```bash
   php artisan serve
   ```

9. **Inicie o Vite para desenvolvimento**
   ```bash
   npm run dev
   ```

Acesse a aplicação em `http://localhost:8000`

## 🔧 Configuração do Banco de Dados

### PostgreSQL
1. Crie o banco de dados:
   ```sql
   CREATE DATABASE financial_system;
   ```

2. Configure o usuário e permissões:
   ```sql
   CREATE USER laravel_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE financial_system TO laravel_user;
   ```

3. Verifique a conexão:
   ```bash
   php artisan tinker
   >>> DB::connection()->getPdo();
   ```

## 📝 Uso do Sistema

### Primeiro Acesso
1. Acesse `http://localhost:8000`
2. Clique em \"Configurar sistema\"
3. Preencha os dados do primeiro administrador
4. Faça login com as credenciais criadas

### Fluxo de Trabalho

#### 1. Cadastro Inicial
- **Funcionários**: Cadastre todos os funcionários da empresa
- **Veículos**: Cadastre todos os veículos da frota
- **Categorias**: Crie categorias financeiras conforme necessidade

#### 2. Operações Diárias
- **Lançamentos Financeiros**: Registre receitas e despesas
- **Custos de Veículos**: Registre combustível, manutenção, etc.
- **Pagamentos**: Registre pagamentos de funcionários

#### 3. Emissão de Recibos
- Após registrar um pagamento, emita o recibo correspondente
- Os recibos são gerados automaticamente com numeração sequencial

## 🌐 API Endpoints

### Autenticação
- `POST /api/auth/check-admin` - Verificar se existe admin

### Dashboard
- `GET /api/dashboard/stats` - Estatísticas do dashboard

### Financeiro
- `GET /api/financial/categories` - Listar categorias
- `GET /api/financial/entries` - Listar lançamentos
- `POST /api/financial/entries` - Criar lançamento
- `PUT /api/financial/entries/{id}` - Atualizar lançamento
- `DELETE /api/financial/entries/{id}` - Excluir lançamento
- `GET /api/financial/summary` - Resumo financeiro

### Veículos
- `GET /api/vehicles` - Listar veículos
- `POST /api/vehicles` - Criar veículo
- `GET /api/vehicles/{id}` - Detalhes do veículo
- `PUT /api/vehicles/{id}` - Atualizar veículo
- `DELETE /api/vehicles/{id}` - Excluir veículo
- `GET /api/vehicles/{id}/costs` - Listar custos do veículo
- `POST /api/vehicles/{id}/costs` - Adicionar custo ao veículo

### Funcionários
- `GET /api/employees` - Listar funcionários
- `POST /api/employees` - Criar funcionário
- `GET /api/employees/{id}` - Detalhes do funcionário
- `PUT /api/employees/{id}` - Atualizar funcionário
- `DELETE /api/employees/{id}` - Excluir funcionário
- `GET /api/employees/{id}/payments` - Listar pagamentos
- `POST /api/employees/{id}/payments` - Adicionar pagamento

## 🔒 Segurança

### Autenticação
- Sistema de login seguro com sessão
- Proteção CSRF em todos os formulários
- Senhas hasheadas com bcrypt
- Middleware de autenticação em rotas protegidas

### Validação
- Validação de dados em todos os formulários
- Sanitização de entrada de dados
- Proteção contra SQL Injection via Eloquent ORM

### Permissões
- Sistema de roles (ADMIN/USER)
- Middleware de verificação de permissões
- Rotas protegidas por nível de acesso

## 🚀 Deploy em Produção

### Build para Produção
```bash
npm run build
```

### Otimizações
- Configurar cache de rota: `php artisan route:cache`
- Configurar cache de configuração: `php artisan config:cache`
- Configurar cache de views: `php artisan view:cache`
- Otimizar autoloader: `composer dump-autoload --optimize`

### Variáveis de Ambiente de Produção
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://seu-dominio.com

DB_CONNECTION=pgsql
DB_HOST=seu-servidor-postgres
DB_PORT=5432
DB_DATABASE=financial_system_prod
DB_USERNAME=usuario_producao
DB_PASSWORD=senha_segura
```

## 🐛 Troubleshooting

### Problemas Comuns

#### Erro de Conexão com PostgreSQL
- Verifique se o PostgreSQL está rodando
- Confirme as credenciais no arquivo `.env`
- Verifique se o banco de dados foi criado

#### Erro de Permissões
- Verifique as permissões dos diretórios `storage` e `bootstrap/cache`
- Execute: `chmod -R 775 storage bootstrap/cache`

#### Erro de Migrations
- Verifique se o banco de dados está vazio
- Execute `php artisan migrate:rollback` para reverter
- Execute `php artisan migrate:fresh` para limpar e recriar

#### Erro de Assets
- Execute `npm install` para instalar dependências
- Execute `npm run build` para compilar assets
- Execute `npm run dev` para desenvolvimento

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor, sinta-se à vontade para enviar um Pull Request.

## 📞 Suporte

Para suporte, envie um email para suporte@seu-dominio.com ou abra uma issue no GitHub.

---

**Desenvolvido com ❤️ usando Laravel e PostgreSQL**