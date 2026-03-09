# build_and_push.sh

Este script automatiza el proceso de **construcción y publicación de las imágenes Docker** del proyecto.

Su objetivo es permitir que las imágenes del **gateway** y del **dashboard** sean generadas y publicadas en **Docker Hub** de forma reproducible.

El script fue diseñado para poder utilizarse tanto:

- **de forma interactiva en desarrollo local**
- **dentro de pipelines o workflows de CI/CD**

El script ejecuta las siguientes etapas:

1. Verifica que **Docker esté instalado** en el sistema.
2. Determina las rutas de los proyectos que contienen los Dockerfiles.
3. Valida que los directorios y Dockerfiles existan.
4. Define los **tags de las imágenes**.
5. Inicia sesión en **Docker Hub**.
6. Construye las imágenes Docker.
7. Publica las imágenes en Docker Hub.

Imágenes generadas:

- `fox-jokes-gateway`
- `fox-jokes-dashboard`

Tags configurables:

```
$DOCKERHUB_USER/fox-jokes-gateway:<tag>
$DOCKERHUB_USER/fox-jokes-dashboard:<tag>
```

### Uso interactivo

El script puede ejecutarse directamente desde la carpeta `scripts`.

```
./build_and_push.sh
```

Durante la ejecución el script solicitará:

- rutas de los proyectos
- usuario de Docker Hub
- contraseña de Docker Hub
- tags para las imágenes

### Uso en pipelines o workflows

El script también puede ejecutarse **sin interacción** utilizando variables de entorno.

Variables soportadas:

```
DEFAULT_DOCKERFILE_PATH=true
GATEWAY_TAG=<tag>
DASHBOARD_TAG=<tag>
DOCKERHUB_USER=<dockerhub_user>
DOCKERHUB_PASSWORD=<dockerhub_password>
```

Ejemplo de ejecución en CI/CD:

```
export DEFAULT_DOCKERFILE_PATH=true
export GATEWAY_TAG=latest
export DASHBOARD_TAG=latest
export DOCKERHUB_USER=myuser
export DOCKERHUB_PASSWORD=mytoken

./build_and_push.sh
```

Esto permite que el script sea integrado fácilmente en:

- GitHub Actions
- GitLab CI
- Jenkins
- cualquier workflow de automatización.

El script utiliza configuración segura para detener la ejecución si ocurre un error.

```
set -euo pipefail
```

Esto evita que el pipeline continúe en caso de fallos durante el build o el push de imágenes.

---

# pull_and_run.sh

Este script automatiza el proceso de **descarga y ejecución local de las imágenes Docker** del proyecto.

Su objetivo es permitir que cualquier usuario pueda ejecutar la aplicación completa utilizando únicamente las imágenes publicadas en Docker Hub.

El script realiza las siguientes operaciones:

1. Verifica que **Docker esté instalado**. 
2. Verifica que los **puertos requeridos estén disponibles**.
3. Inicia sesión en **Docker Hub**.
4. Consulta los **tags disponibles** de las imágenes del proyecto.
5. Descarga las imágenes seleccionadas.
6. Ejecuta los contenedores.
7. Configura la comunicación entre gateway y dashboard.

Contenedores ejecutados:

- `fox-jokes-gateway`
- `fox-jokes-dashboard`

### Selección de puertos

El script permite configurar los puertos de ejecución.

Por defecto:

```
Gateway   → 5050
Dashboard → 80
```

Esto permite evitar conflictos con otros servicios ejecutándose en la máquina.

### Ejecución de los contenedores

El gateway se inicia primero:

```
docker run -d \
--name fox-jokes-gateway \
-p $GATEWAY_PORT:80 \
"$DOCKERHUB_USER/fox-jokes-gateway:$GATEWAY_TAG"
```

Luego se inicia el dashboard configurando dinámicamente la URL del gateway:

```
docker run -d \
--name fox-jokes-dashboard \
-p $DASHBOARD_PORT:80 \
-e API_URL="http://localhost:$GATEWAY_PORT" \
"$DOCKERHUB_USER/fox-jokes-dashboard:$DASHBOARD_TAG"
```

La variable `API_URL` permite que el frontend conozca la dirección del gateway.

### Uso

```
./pull_and_run.sh
```

El script:

- descarga las imágenes desde Docker Hub
- ejecuta ambos contenedores
- muestra las URLs de acceso

Ejemplo de salida:

```
Gateway disponible en:
http://localhost:5050

Dashboard disponible en:
http://localhost:80
```

### Finalización

El script mantiene los contenedores activos hasta que el usuario presiona **Ctrl+C**.

Al recibir la señal de interrupción el script:

- detiene los contenedores
- elimina los contenedores creados

Esto permite ejecutar la aplicación de forma temporal sin dejar recursos activos en el sistema.