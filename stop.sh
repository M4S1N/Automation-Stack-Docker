#!/bin/bash

echo "🛑 Deteniendo y eliminando contenedores..."

docker stop n8n open-webui qdrant
docker rm n8n open-webui qdrant
