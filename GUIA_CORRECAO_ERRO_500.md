# Guia Completo para Corrigir Erro 500 no Laravel

## 🚨 Problema: Erro 500 ao acessar a aplicação

Se você está recebendo um erro 500 ao tentar acessar o sistema de gestão financeira, siga este guia passo a passo para resolver o problema.

## 🔍 Causas Comuns do Erro 500

1. **APP_KEY não gerada** - Chave de aplicação não configurada
2. **Assets não compilados** - Arquivos CSS/JS não foram construídos
3. **Permissões incorretas** - Diretórios storage e bootstrap sem permissão adequada
4. **Cache do Laravel** - Cache corrompido ou desatualizado
5. **Conexão com banco de dados** - Problemas na configuração do PostgreSQL
6. **Dependências faltando** - Node.js modules não instalados
7. **Diretórios ausentes** - Estrutura de diretórios do Laravel incompleta

## 🛠️ Solução Automática (Recomendado)

### 1. Execute o Script de Correção

```bash
# Navegue até o diretório do projeto
cd gestao

# Execute o script de correção automática
./fix_erro_500.sh
```

Este script irá:
- ✅ Gerar a APP_KEY automaticamente
- ✅ Limpar todo o cache do Laravel
- ✅ Criar diretórios necessários
- ✅ Configurar permissões corretas
- ✅ Instalar dependências Node.js
- ✅ Compilar assets
- ✅ Verificar conexão com banco de dados
- ✅ Criar links simbólicos necessários

## 🔧 Solução Manual (Passo a Passo)

Se preferir resolver manualmente, siga estes passos:

### 1. Verificar e Gerar APP_KEY

```bash
# Verificar se a APP_KEY está configurada
grep APP_KEY .env

# Se mostrar "base64:your-app-key-here", gere uma nova chave
php artisan key:generate
```

### 2. Limpar Cache do Laravel

```bash
# Limpar todo o cache
php artisan optimize:clear
php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear
```

### 3. Criar Diretórios Necessários

```bash
# Criar estrutura de diretórios storage
mkdir -p storage/logs
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/app/public
mkdir -p bootstrap/cache
```

### 4. Configurar Permissões

```bash
# Configurar permissões corretas
chmod -R 775 storage
chmod -R 775 bootstrap/cache
chmod 644 .env
```

### 5. Instalar Dependências Node.js

```bash
# Instalar dependências
npm install

# Compilar assets para produção
npm run build
```

### 6. Verificar Conexão com Banco de Dados

```bash
# Testar conexão com PostgreSQL
php artisan tinker --execute="echo 'Conexão: ' . (DB::connection()->getPdo() ? 'OK' : 'FALHA');"
```

### 7. Verificar Migrations

```bash
# Verificar status das migrations
php artisan migrate:status

# Se a tabela de migrations não existir
php artisan migrate:install

# Rodar migrations
php artisan migrate --force
```

### 8. Criar Link Simbólico

```bash
# Criar link para storage público
php artisan storage:link
```

### 9. Otimizar Laravel

```bash
# Otimizar aplicação
php artisan optimize
```

## 🔍 Verificação de Logs

Se o erro persistir, verifique os logs do Laravel:

```bash
# Verificar logs de erro
tail -f storage/logs/laravel.log

# Verificar logs do PHP (se estiver usando servidor web)
tail -f /var/log/apache2/error.log
tail -f /var/log/nginx/error.log
```

## 🚀 Iniciar a Aplicação

Após seguir os passos acima, inicie a aplicação:

```bash
# Iniciar servidor de desenvolvimento
php artisan serve

# Iniciar servidor de desenvolvimento de assets (em outro terminal)
npm run dev
```

Acesse: http://localhost:8000

## 📋 Verificação Final

Use este checklist para garantir que tudo está configurado:

- [ ] APP_KEY gerada e configurada
- [ ] Diretórios storage criados com permissões corretas
- [ ] Dependências Node.js instaladas
- [ ] Assets compilados (arquivos em public/build/)
- [ ] Cache do Laravel limpo
- [ ] Conexão com PostgreSQL funcionando
- [ ] Migrations executadas
- [ ] Link simbólico storage criado
- [ ] Arquivo .env configurado corretamente

## 🆘 Problemas Específicos

### Problema: Assets não carregam (CSS/JS)

**Solução:**
```bash
# Iniciar servidor de desenvolvimento
npm run dev

# Ou compilar para produção
npm run build
```

### Problema: Erro de conexão com banco de dados

**Solução:**
1. Verifique se o PostgreSQL está rodando: `sudo systemctl status postgresql`
2. Verifique as credenciais no arquivo `.env`
3. Teste a conexão: `psql -h localhost -U ieducar -d gestao_financeira`

### Problema: Permissões negadas

**Solução:**
```bash
# Configurar permissões corretas
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### Problema: Tabela de migrations não existe

**Solução:**
```bash
# Criar tabela de migrations
php artisan migrate:install --force

# Rodar migrations
php artisan migrate --force
```

## 🎯 Próximos Passos

Após resolver o erro 500:

1. **Acesse o sistema**: http://localhost:8000
2. **Configure o administrador**: Acesse `/setup` para criar o primeiro usuário
3. **Faça login**: Use as credenciais de administrador
4. **Configure o servidor web**: Apache ou Nginx para produção
5. **Configure SSL**: HTTPS para ambiente de produção

## 📞 Suporte

Se o problema persistir após seguir todos os passos:

1. Verifique os logs em `storage/logs/laravel.log`
2. Execute `php artisan tinker` para testar comandos manualmente
3. Verifique a configuração do servidor web (Apache/Nginx)
4. Consulte a documentação do Laravel para problemas específicos

---

**Lembre-se**: O erro 500 geralmente indica um problema de configuração e não um bug no código. Seguir este guia passo a passo deve resolver a maioria dos problemas.