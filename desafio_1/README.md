# Arquitectura del Desafío 1

El desafío se organiza en tres componentes principales dentro de la carpeta `desafio_1`.  
Cada uno cumple una función específica dentro de la arquitectura de la solución.

Estructura general:

```
desafio_1
├── apps
├── helm
└── scripts
```

Cada carpeta representa una capa distinta del flujo de desarrollo y despliegue:

- **apps** → código de la aplicación y contenedores
- **helm** → despliegue en Kubernetes
- **scripts** → automatización del ciclo de build y ejecución

---

# Aplicación y Contenedores (`apps`)

La carpeta `apps` contiene los componentes principales de la aplicación y los contenedores necesarios para ejecutarla.

Estructura:

```
apps
├── fox_jokes_dashboard
└── fox_jokes_gateway
```

## fox_jokes_dashboard

Aplicación frontend desarrollada con **Vue 3** y **Vite**.  
Su función es mostrar un dashboard que presenta:

- un chiste de programación (JokeAPI)
- una imagen aleatoria de un zorro (RandomFox API)

La aplicación está estructurada en componentes reutilizables y preparada para ejecutarse dentro de un contenedor Docker.

Un aspecto importante de la arquitectura es que **el frontend no realiza llamadas directas a las APIs externas**.  
En su lugar, utiliza un gateway interno que expone endpoints controlados.

## fox_jokes_gateway

El gateway se implementa utilizando **Nginx** y funciona como proxy hacia las APIs externas.

Este contenedor expone rutas internas que el frontend consume:

- `/api/joke`
- `/api/fox`

Estas rutas son redirigidas hacia las APIs externas correspondientes.

El gateway se construye utilizando una imagen ligera basada en `nginx:alpine`.


Separar el gateway del frontend permite:

- centralizar las llamadas externas
- simplificar la gestión de CORS
- desacoplar la configuración de APIs del código del frontend
- facilitar despliegues en entornos containerizados.

Para más detalles sobre la implementación de la aplicación y los contenedores, consultar:

[apps/README.md](./apps/README.md)

---

# Despliegue en Kubernetes (`helm`)

La carpeta `helm` contiene los **Helm charts** diseñados para desplegar la aplicación en un cluster de Kubernetes.

Estructura:

```
helm
├── fox-jokes-dashboard
├── fox-jokes-gateway
└── fox-jokes-stack
```

Se diseñaron charts independientes para cada componente de la aplicación y un chart adicional que permite desplegar todo el stack.

Esto permite:

- desplegar servicios de forma modular
- reutilizar configuraciones
- gestionar despliegues mediante Helm

Los charts definen:

- deployments
- services
- ingress
- variables configurables mediante `values.yaml`

Para más detalles sobre la configuración y uso de los charts:

[helm/README.md](./helm/README.md)

---

# Automatización de Build y Ejecución (`scripts`)

La carpeta `scripts` contiene herramientas de automatización para manejar el ciclo de vida de las imágenes Docker.

Estructura:

```
scripts
├── build_and_push.sh
└── pull_and_run.sh
```

Los scripts permiten:

- construir las imágenes Docker del proyecto
- etiquetar las imágenes
- publicarlas en Docker Hub
- descargar las imágenes desde el registro
- ejecutar los contenedores localmente

Esto permite reproducir el proceso completo de despliegue de forma simple y consistente.

Para más detalles sobre el uso de los scripts:

[scripts/README.md](./scripts/README.md)

---

# Resumen de Arquitectura

La solución del desafío se compone de tres capas claramente separadas:

1. **Aplicación (`apps`)**
   - frontend Vue
   - gateway Nginx
   - contenedores Docker

2. **Infraestructura de despliegue (`helm`)**
   - charts para Kubernetes
   - despliegue modular de los servicios

3. **Automatización (`scripts`)**
   - build de imágenes
   - publicación en Docker Hub
   - ejecución local

Esta separación permite que la aplicación sea fácilmente desplegable tanto en entornos locales como en plataformas de orquestación como Kubernetes.