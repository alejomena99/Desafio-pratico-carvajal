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
# Definir rutas por defecto de los proyectos
# =========================================================

DEFAULT_GATEWAY_PATH="../apps/fox_jokes_gateway"
DEFAULT_DASHBOARD_PATH="../apps/fox_jokes_dashboard"


# =========================================================
# Determinar rutas de los proyectos
# =========================================================

if [ "${DEFAULT_DOCKERFILE_PATH:-}" = "true" ]; then

  echo "Variable de entorno DEFAULT_DOCKERFILE_PATH encontrada y habilitada."

  GATEWAY_PATH="$DEFAULT_GATEWAY_PATH"
  DASHBOARD_PATH="$DEFAULT_DASHBOARD_PATH"

else

  echo "Por defecto se usarán las siguientes rutas para los Dockerfiles:"
  echo "Gateway:    $DEFAULT_GATEWAY_PATH/Dockerfile"
  echo "Dashboard:  $DEFAULT_DASHBOARD_PATH/Dockerfile"
  echo

  read -p "¿Desea usar estas rutas? (y/n): " USE_DEFAULT

  if [[ "$USE_DEFAULT" =~ ^[Yy]$ ]]; then
    GATEWAY_PATH="$DEFAULT_GATEWAY_PATH"
    DASHBOARD_PATH="$DEFAULT_DASHBOARD_PATH"
  else
    read -p "Ingrese la ruta del proyecto Gateway: " GATEWAY_PATH
    read -p "Ingrese la ruta del proyecto Dashboard: " DASHBOARD_PATH
  fi

fi


# =========================================================
# Mostrar rutas que serán utilizadas
# =========================================================

echo
echo "Rutas que se utilizarán:"
echo "Gateway:   $GATEWAY_PATH"
echo "Dashboard: $DASHBOARD_PATH"


# =========================================================
# Validar que los directorios existan
# =========================================================

if [ ! -d "$GATEWAY_PATH" ]; then
  echo "Error: el directorio Gateway no existe: $GATEWAY_PATH"
  exit 1
fi

if [ ! -d "$DASHBOARD_PATH" ]; then
  echo "Error: el directorio Dashboard no existe: $DASHBOARD_PATH"
  exit 1
fi


# =========================================================
# Validar que los Dockerfiles existan
# =========================================================

if [ ! -f "$GATEWAY_PATH/Dockerfile" ]; then
  echo "Error: No se encontró Dockerfile en $GATEWAY_PATH"
  exit 1
fi

if [ ! -f "$DASHBOARD_PATH/Dockerfile" ]; then
  echo "Error: No se encontró Dockerfile en $DASHBOARD_PATH"
  exit 1
fi

echo "Dockerfiles encontrados."


# =========================================================
# Configuración del tag de las imágenes
# =========================================================

DEFAULT_TAG="latest"

# -----------------------------
# Tag para fox-jokes-gateway
# -----------------------------
if [ -z "${GATEWAY_TAG:-}" ]; then
  read -p "Ingrese el tag para fox-jokes-gateway [${DEFAULT_TAG}]: " GATEWAY_TAG
  GATEWAY_TAG=${GATEWAY_TAG:-$DEFAULT_TAG}
else
  echo "Variable de entorno GATEWAY_TAG encontrada: $GATEWAY_TAG"
fi


# -----------------------------
# Tag para fox-jokes-dashboard
# -----------------------------
if [ -z "${DASHBOARD_TAG:-}" ]; then
  read -p "Ingrese el tag para fox-jokes-dashboard [${DEFAULT_TAG}]: " DASHBOARD_TAG
  DASHBOARD_TAG=${DASHBOARD_TAG:-$DEFAULT_TAG}
else
  echo "Variable de entorno DASHBOARD_TAG encontrada: $DASHBOARD_TAG"
fi


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
# Construir imagen del Gateway
# =========================================================

echo "Construyendo imagen fox-jokes-gateway..."

docker build \
  -t "$DOCKERHUB_USER/fox-jokes-gateway:$GATEWAY_TAG" \
  "$GATEWAY_PATH"


# =========================================================
# Construir imagen del Dashboard
# =========================================================

echo "Construyendo imagen fox-jokes-dashboard..."

docker build \
  -t "$DOCKERHUB_USER/fox-jokes-dashboard:$DASHBOARD_TAG" \
  "$DASHBOARD_PATH"


# =========================================================
# Subir imagen del Gateway a Docker Hub
# =========================================================

echo "Subiendo imagen fox-jokes-gateway a Docker Hub..."
docker push "$DOCKERHUB_USER/fox-jokes-gateway:$GATEWAY_TAG"


# =========================================================
# Subir imagen del Dashboard a Docker Hub
# =========================================================

echo "Subiendo imagen fox-jokes-dashboard a Docker Hub..."
docker push "$DOCKERHUB_USER/fox-jokes-dashboard:$DASHBOARD_TAG"


# =========================================================
# Mostrar resumen final
# =========================================================

echo
echo "Imágenes publicadas correctamente en Docker Hub:"
echo "$DOCKERHUB_USER/fox-jokes-gateway:$GATEWAY_TAG"
echo "$DOCKERHUB_USER/fox-jokes-dashboard:$DASHBOARD_TAG"