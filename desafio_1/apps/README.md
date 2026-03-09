# fox_jokes_gateway

Esta carpeta contiene el **gateway de la aplicación**, implementado utilizando **Nginx**.  
Su función es actuar como **proxy entre el frontend y las APIs externas**.

El objetivo de este componente es evitar que el frontend consuma directamente servicios externos, centralizando el acceso a las APIs desde un único punto.

Estructura:

```
fox_jokes_gateway
├── Dockerfile
└── default.conf
```

---

## Contenedor del Gateway

El gateway se ejecuta como un contenedor Docker basado en **Nginx Alpine**, una imagen ligera adecuada para entornos containerizados.

Dockerfile:

```
FROM nginx:alpine

# Copiar configuración del gateway
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

Decisiones de diseño:

**Imagen ligera**

Se utiliza `nginx:alpine` para reducir el tamaño de la imagen y mejorar los tiempos de descarga y despliegue.

**Configuración desacoplada**

La lógica de proxy se define en el archivo `default.conf`, lo que permite modificar endpoints externos sin necesidad de cambiar la aplicación frontend.

**Ejecución en primer plano**

Se utiliza `daemon off` para mantener Nginx ejecutándose en foreground, práctica estándar para contenedores Docker.

---

## Configuración del Proxy

El archivo `default.conf` define las rutas internas que el frontend utilizará para consumir las APIs externas. :contentReference[oaicite:0]{index=0}

Configuración:

```
server {
    listen 80;

    # JokeAPI
    location /api/joke {
        proxy_pass https://v2.jokeapi.dev/joke/Programming?type=single;
        proxy_ssl_server_name on;
    }

    # RandomFox
    location /api/fox {
        proxy_pass https://randomfox.ca/floof/;
        proxy_ssl_server_name on;
    }
}
```

Rutas expuestas por el gateway:

| Endpoint interno | API externa |
|------------------|-------------|
| `/api/joke` | JokeAPI |
| `/api/fox` | RandomFox API |

---

## Flujo de Solicitudes

El gateway actúa como intermediario entre el navegador y las APIs externas.

Flujo:

```
Browser
   │
   │ request /api/joke
   │ request /api/fox
   ▼
Nginx Gateway
   │
   ├── JokeAPI
   └── RandomFox API
```

El frontend solo interactúa con el gateway, lo que permite mantener desacoplado el acceso a servicios externos.

---

# fox_jokes_dashboard

Esta carpeta contiene la **aplicación frontend** del proyecto.  
El dashboard fue desarrollado utilizando **Vue 3** y **Vite**, y su objetivo es mostrar información obtenida desde el gateway de la aplicación.

El frontend presenta dos tipos de información:

- un **chiste de programación**
- una **imagen aleatoria de un zorro**

Ambos datos son obtenidos desde el gateway utilizando los endpoints internos:

- `/api/joke`
- `/api/fox`

Esto mantiene desacoplado el frontend de las APIs externas y permite que la comunicación con servicios externos sea controlada por el gateway.

Estructura principal:

```
fox_jokes_dashboard
├── public
│   └── env
│       └── env.js
│
├── src
│   ├── components
│   │   ├── FoxCard.vue
│   │   └── JokeCard.vue
│   │
│   ├── views
│   │   └── Dashboard.vue
│   │
│   ├── router
│   │   └── index.js
│   │
│   ├── stores
│   │   └── counter.js
│   │
│   ├── App.vue
│   └── main.js
│
├── Dockerfile
├── entrypoint.sh
├── index.html
├── package.json
└── vite.config.js
```

## Arquitectura del Frontend

La aplicación sigue una estructura típica de proyectos Vue.

- **components** → componentes reutilizables
- **views** → vistas principales
- **router** → configuración de rutas
- **stores** → gestión de estado global con Pinia

Componentes principales:

**JokeCard.vue**

Obtiene un chiste desde el endpoint `/api/joke`.

**FoxCard.vue**

Obtiene una imagen desde `/api/fox`.

Ambos componentes son renderizados dentro de **Dashboard.vue**, que constituye la vista principal de la aplicación.

La inicialización del frontend se realiza en `main.js`, donde se crea la instancia de Vue y se registran los plugins principales.

```
const app = createApp(App)

app.use(createPinia())
app.use(router)

app.mount('#app')
```

El proyecto utiliza **Vite** como herramienta de build y servidor de desarrollo.

Ventajas principales:

- arranque rápido del servidor de desarrollo
- hot reload
- build optimizado para producción

También se define un alias `@` para simplificar imports dentro del proyecto.

## Contenedor del Frontend

El dashboard está preparado para ejecutarse dentro de un contenedor Docker.

El contenedor sirve los archivos generados por Vite utilizando **Nginx** y permite configurar el endpoint del gateway mediante variables de entorno en tiempo de ejecución.

Dockerfile:

```
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
```

Decisiones de diseño:

**Build separado**

Se utiliza una imagen Node para compilar la aplicación y luego se copian los archivos generados al contenedor Nginx.  
Esto reduce el tamaño final de la imagen.

**Nginx para servir contenido estático**

El contenedor final utiliza Nginx para servir los archivos generados por Vite.

**ENTRYPOINT**

El `ENTRYPOINT` ejecuta el script `entrypoint.sh` cuando el contenedor inicia.

Este script genera dinámicamente el archivo `env.js`, que contiene la configuración del gateway.

Esto permite configurar el endpoint del gateway utilizando variables de entorno sin reconstruir la imagen.

**CMD**

El `CMD` ejecuta Nginx en foreground.

```
CMD ["nginx", "-g", "daemon off;"]
```

Esto mantiene el proceso activo dentro del contenedor, que es el comportamiento esperado en Docker.

## Variables de entorno dinámicas

La URL del gateway se define mediante un archivo generado dinámicamente.

```
window._env_ = {
  API_URL: "https://gateway.com"
}
```

Este archivo es generado por `entrypoint.sh` cuando el contenedor inicia.

El archivo `index.html` carga esta configuración antes de iniciar la aplicación Vue.

```
<script src="/env/env.js"></script>
```

Esto permite utilizar la misma imagen Docker en distintos entornos cambiando únicamente las variables de entorno del contenedor.