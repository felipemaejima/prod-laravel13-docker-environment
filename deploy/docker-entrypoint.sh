#!/bin/sh
set -e

cd /app

# Garante que o .env existe (em produção, normalmente vem via
# variáveis de ambiente do `docker run`, mas mantemos o fallback)
if [ ! -f .env ]; then
    echo "Aviso: .env não encontrado. Usando variáveis de ambiente."
fi

# Gera APP_KEY se não houver uma definida
if [ -z "$APP_KEY" ] && ! grep -q "^APP_KEY=base64" .env 2>/dev/null; then
    echo "Gerando APP_KEY..."
    php artisan key:generate --force
fi

# Roda as migrations (--force: obrigatório em produção, pula confirmação)
echo "Rodando migrations..."
php artisan migrate --force

# Aplica os caches de produção (config, rotas, views)
# Aceleram o boot e o atendimento das requisições.
echo "Aplicando caches de produção..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Inicialização concluída. Subindo o FrankenPHP..."

# Sobe o servidor. As flags de SERVER_NAME e SERVER_ROOT vêm do
# ambiente (definidas no Dockerfile / docker run).
exec frankenphp run --config /etc/frankenphp/Caddyfile
