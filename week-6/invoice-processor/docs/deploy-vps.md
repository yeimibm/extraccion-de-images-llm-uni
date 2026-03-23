# Despliegue en VPS Ubuntu 24.04 con Docker Compose

## 1. Preparar el repositorio local

Si quieres que este proyecto apunte al nuevo repositorio:

```bash
git remote remove origin
git remote add origin https://github.com/yeimibm/extraccion-de-images-llm-uni.git
git add .
git commit -m "Prepare production deployment with Docker Compose"
git push -u origin main
```

Si tu rama principal no es `main`, cambia el nombre en el último comando.

## 2. Preparar el VPS

Conéctate por SSH como `root` y ejecuta:

```bash
apt update && apt upgrade -y
apt install -y docker.io docker-compose-v2 nginx git ufw
systemctl enable --now docker
systemctl enable --now nginx
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable
```

## 3. Clonar el proyecto

```bash
cd /opt
git clone https://github.com/yeimibm/extraccion-de-images-llm-uni.git
cd extraccion-de-images-llm-uni/week-6/invoice-processor
```

## 4. Configurar variables de entorno

```bash
cp .env.example .env
nano .env
```

Valores mínimos recomendados:

```env
OPENAI_API_KEY=tu_api_key_real
OPENAI_MODEL=gpt-4.1-mini
API_PORT=3001
NEXT_PUBLIC_API_URL=http://TU_IP_PUBLICA/api
DATABASE_URL=./data/invoices.db
UPLOADS_DIR=./uploads
DB_DRIVER=sqlite
```

Si luego configuras dominio y HTTPS, cambia `NEXT_PUBLIC_API_URL` a `https://tu-dominio.com/api`.

## 5. Levantar contenedores

```bash
docker compose build
docker compose up -d
docker compose ps
```

La webapp quedará escuchando solo en `127.0.0.1:3000` y el API solo en `127.0.0.1:3001`.

## 6. Configurar Nginx como reverse proxy

```bash
cp ops/nginx/invoice-processor.conf /etc/nginx/sites-available/invoice-processor
ln -s /etc/nginx/sites-available/invoice-processor /etc/nginx/sites-enabled/invoice-processor
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx
```

Con eso:

- `/` apunta al frontend en Docker
- `/api/` apunta al backend
- `/uploads/` sirve previews y descargas

## 7. Acceder desde la IP pública

Abre en tu navegador:

```text
http://TU_IP_PUBLICA
```

## 8. Comandos útiles de operación

```bash
docker compose logs -f
docker compose pull
docker compose build --no-cache
docker compose up -d
docker compose down
```

## 9. HTTPS más adelante

Cuando ya tengas dominio apuntando al VPS, puedes agregar Let's Encrypt con Certbot en el host:

```bash
apt install -y certbot python3-certbot-nginx
certbot --nginx -d tu-dominio.com -d www.tu-dominio.com
```
