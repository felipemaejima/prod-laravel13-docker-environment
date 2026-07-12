# 1. Buildar a imagem
docker build -f deploy/Dockerfile -t {APP_NAME} .

# 2. Parar o container antigo
docker stop laravel-app 2>/dev/null; docker rm laravel-app 2>/dev/null

# 3. Subir o novo (com .env via --env-file)
docker run -d --name laravel-app \
  -e SERVER_NAME="{APP_HOST}" \
  --env-file .env \
  -p 80:80 \
  -p 443:443 \
  -p 443:443/udp \
  {APP_NAME}

# 4. Acompanhar os logs do boot (migrations, caches, server)
docker logs -f laravel-app
