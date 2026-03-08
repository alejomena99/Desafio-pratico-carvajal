#!/usr/bin/env bash

# =========================================================
# Configuración segura del script
# -e  : termina si un comando falla
# -u  : falla si se usa una variable no definida
# pipefail : detecta errores dentro de pipes
# =========================================================
set -euo pipefail


# =========================================================
# Verificar que Docker esté instalado
# =========================================================

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker no está instalado."
  exit 1
fi

VERSION=$(docker version --format '{{.Client.Version}}')
echo "Docker está instalado. Versión: $VERSION"


# =========================================================
# Verificar que los puertos necesarios estén disponibles
# =========================================================

check_port() {
  local PORT=$1

  if ss -tuln | grep -q ":$PORT "; then
    echo "Error: El puerto $PORT ya está en uso."
    exit 1
  else
    echo "Puerto $PORT disponible."
  fi
}

echo "Configuración de puertos para port-forward"
echo

# -----------------------------
# Puerto para Gateway
# -----------------------------
DEFAULT_GATEWAY_PORT=5050

read -p "Ingrese el puerto para fox-jokes-gateway [$DEFAULT_GATEWAY_PORT]: " GATEWAY_PORT
GATEWAY_PORT=${GATEWAY_PORT:-$DEFAULT_GATEWAY_PORT}

# -----------------------------
# Puerto para Dashboard
# -----------------------------
DEFAULT_DASHBOARD_PORT=80

read -p "Ingrese el puerto para fox-jokes-dashboard [$DEFAULT_DASHBOARD_PORT]: " DASHBOARD_PORT
DASHBOARD_PORT=${DASHBOARD_PORT:-$DEFAULT_DASHBOARD_PORT}

# =========================================================
# Validar que los puertos no sean iguales
# =========================================================

if [ "$GATEWAY_PORT" -eq "$DASHBOARD_PORT" ]; then
  echo "Error: Gateway y Dashboard no pueden usar el mismo puerto."
  exit 1
fi

# =========================================================
# Verificar disponibilidad de puertos
# =========================================================

echo
echo "Verificando disponibilidad de puertos..."

check_port "$GATEWAY_PORT"
check_port "$DASHBOARD_PORT"

echo
echo "Todos los puertos requeridos están disponibles."
echo "Gateway se expondrá en: $GATEWAY_PORT"
echo "Dashboard se expondrá en: $DASHBOARD_PORT"
echo

# =========================================================
# Solicitar credenciales de Docker Hub
# =========================================================

if [ -z "${DOCKERHUB_USER:-}" ]; then
  read -p "Ingrese su usuario de Docker Hub: " DOCKERHUB_USER
else
  echo "Variable de entorno DOCKERHUB_USER encontrada."
fi


if [ -z "${DOCKERHUB_PASSWORD:-}" ]; then
  read -s -p "Ingrese su contraseña de Docker Hub: " DOCKERHUB_PASSWORD
  echo
else
  echo "Variable de entorno DOCKERHUB_PASSWORD encontrada."
fi


# =========================================================
# Crear configuración temporal de Docker
# =========================================================

export DOCKER_CONFIG
DOCKER_CONFIG=$(mktemp -d)

trap 'rm -rf "$DOCKER_CONFIG"' EXIT


# =========================================================
# Iniciar sesión en Docker Hub
# =========================================================

echo "Iniciando sesión en Docker Hub..."

if echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USER" --password-stdin >/dev/null 2>&1; then
  echo "Login exitoso en Docker Hub."
else
  echo "Error al iniciar sesión en Docker Hub."
  exit 1
fi


# =========================================================
# Buscar imágenes específicas en el repositorio del usuario
# y listar sus tags disponibles en Docker Hub
# =========================================================

echo "Buscando imágenes fox-jokes en el repositorio de $DOCKERHUB_USER..."
echo

REPOS=$(curl -s "https://hub.docker.com/v2/repositories/$DOCKERHUB_USER/?page_size=100" \
| grep -o '"name":"[^"]*' \
| cut -d'"' -f4 \
| grep -E 'fox-jokes-gateway|fox-jokes-dashboard')

for IMAGE in $REPOS
do
  echo "Tags disponibles para $IMAGE:"
  
  curl -s "https://hub.docker.com/v2/repositories/$DOCKERHUB_USER/$IMAGE/tags?page_size=100" \
  | grep -o '"name":"[^"]*' \
  | cut -d'"' -f4
  
  echo
done

echo "Listado de imágenes y tags completado."
echo


# =========================================================
# Solicitar el tag a utilizar para cada imagen
# =========================================================

read -p "Ingrese el tag para fox-jokes-gateway [latest]: " GATEWAY_TAG
GATEWAY_TAG=${GATEWAY_TAG:-latest}

read -p "Ingrese el tag para fox-jokes-dashboard [latest]: " DASHBOARD_TAG
DASHBOARD_TAG=${DASHBOARD_TAG:-latest}

echo
echo "Se utilizarán los siguientes tags:"
echo "Gateway:   $GATEWAY_TAG"
echo "Dashboard: $DASHBOARD_TAG"
echo


# =========================================================
# Descargar imágenes desde Docker Hub
# =========================================================

echo "Descargando imagen fox-jokes-gateway..."
docker pull "$DOCKERHUB_USER/fox-jokes-gateway:$GATEWAY_TAG"

echo "Descargando imagen fox-jokes-dashboard..."
docker pull "$DOCKERHUB_USER/fox-jokes-dashboard:$DASHBOARD_TAG"

echo "Imágenes descargadas correctamente."
echo


# =========================================================
# Función de limpieza al cerrar el script
# =========================================================

cleanup() {

  echo
  echo "Ctrl+C detectado. Deteniendo contenedores..."

  docker stop fox-jokes-gateway 2>/dev/null || true
  docker stop fox-jokes-dashboard 2>/dev/null || true

  echo "Eliminando contenedores..."

  docker rm fox-jokes-gateway 2>/dev/null || true
  docker rm fox-jokes-dashboard 2>/dev/null || true

  echo "Contenedores detenidos y eliminados."
}

trap cleanup SIGINT SIGTERM


# =========================================================
# Ejecutar contenedores Docker
# =========================================================

echo "Iniciando contenedor fox-jokes-gateway en puerto $GATEWAY_PORT..."

docker run -d \
--name fox-jokes-gateway \
-p $GATEWAY_PORT:80 \
"$DOCKERHUB_USER/fox-jokes-gateway:$GATEWAY_TAG"


echo "Iniciando contenedor fox-jokes-dashboard en puerto $DASHBOARD_PORT..."

docker run -d \
--name fox-jokes-dashboard \
-p $DASHBOARD_PORT:80 \
-e API_URL="http://localhost:$GATEWAY_PORT" \
"$DOCKERHUB_USER/fox-jokes-dashboard:$DASHBOARD_TAG"


echo
echo "Contenedores iniciados correctamente."
echo

echo "Gateway disponible en:"
echo "http://localhost:$GATEWAY_PORT"

echo
echo "Dashboard disponible en:"
echo "http://localhost:$DASHBOARD_PORT"

echo
echo "Presione Ctrl+C para detener los contenedores y salir."


# =========================================================
# Mantener el script corriendo hasta Ctrl+C
# =========================================================

while true
do
  sleep 1
done