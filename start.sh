#!/bin/bash

set -e

echo "🔧 Creando red 'internal' si no existe..."
docker network inspect internal >/dev/null 2>&1 || docker network create internal

echo "📦 Creando volúmenes si no existen..."
docker volume create n8n_data >/dev/null || true
docker volume create open-webui-data >/dev/null || true
docker volume create qdrant_data >/dev/null || true

echo "🐳 Construyendo imágenes Docker personalizadas..."
docker build -t custom-n8n ./n8n
docker build -t custom-openwebui ./open-webui
docker build -t custom-qdrant ./qdrant

echo "🚀 Iniciando contenedores..."

docker run -d \
  --name n8n \
  --network internal \
  -p 6789:6789 \
  -v n8n_data:/home/node/.n8n \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=admin \
  -e N8N_HOST=n8n \
  -e N8N_PORT=6789 \
  -e N8N_SECURE_COOKIE=false \
  -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
  -e N8n_RUNNERS_ENABLED=true \
  -e N8N_LOG_LEVEL=debug \
  -e N8N_ENCRYPTION_KEY=CpEMNDGDE9cRi8KP1mM0rkDLBIyAUPH3 \
  -e WEBHOOK_URL=http://localhost:6789 \
  custom-n8n

docker run -d \
  --name open-webui \
  --network internal \
  -p 3000:8080 \
  -v open-webui-data:/app/backend/data \
  custom-openwebui

docker run -d \
  --name qdrant \
  --network internal \
  -p 6333:6333 \
  -v qdrant_data:/qdrant/storage \
  custom-qdrant

echo "✅ Todo listo. Servicios corriendo:"
docker ps
