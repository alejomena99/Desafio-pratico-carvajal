# fox-jokes-dashboard

Este chart despliega el **frontend del dashboard** dentro de Kubernetes.

El chart está diseñado para ser **reutilizable y configurable**, permitiendo que sea desplegado directamente o utilizado como **dependencia dentro de un chart de nivel superior** (por ejemplo `fox-jokes-stack`).

Estructura:

```
fox-jokes-dashboard
├── Chart.yaml
├── values.yaml
└── templates
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── _helpers.tpl
```

El chart define los recursos necesarios para ejecutar el dashboard dentro del cluster:

- Deployment
- Service
- Ingress

---

## Chart.yaml

El archivo `Chart.yaml` define la metadata del chart. :contentReference[oaicite:0]{index=0}

```
apiVersion: v2
name: fox-jokes-dashboard
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.16.0"
```

Puntos importantes:

- **type: application** indica que el chart despliega recursos directamente.
- **version** controla la versión del chart.
- **appVersion** representa la versión de la aplicación desplegada.

Este chart puede ser utilizado como **componente dentro de un stack mayor**, permitiendo reutilizar su configuración.

---

## values.yaml

El archivo `values.yaml` define las variables configurables del chart. :contentReference[oaicite:1]{index=1}

Variables principales:

```
replicaCount:

image:
  repository:
  tag:
  pullPolicy:

service:
  type:
  port:

containerPort:

env:

ingress:
  enabled:
  host:
  path:
```

Esto permite que el chart sea **completamente configurable sin modificar los templates**.

Ejemplos de configuraciones posibles:

- definir el **repositorio de la imagen**
- seleccionar el **tag del contenedor**
- configurar **variables de entorno**
- habilitar o deshabilitar **ingress**
- cambiar el **puerto del servicio**

Este enfoque permite que el chart sea utilizado como **dependencia dentro de otros charts**, pasando los valores desde el chart padre.

---

## Deployment

El `Deployment` define el contenedor que ejecuta el dashboard. :contentReference[oaicite:2]{index=2}

Puntos clave:

- El número de réplicas es configurable.
- La imagen del contenedor se define desde `values.yaml`.
- Las variables de entorno pueden ser definidas dinámicamente.

```
containers:
  - name: dashboard
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

Esto permite que el chart pueda desplegar distintas versiones del dashboard sin modificar el template.

El deployment también permite configurar variables de entorno:

```
env:
  - name: API_URL
    value: ...
```

Esto es necesario para que el frontend conozca la dirección del gateway.

---

## Service

El `Service` expone el dashboard dentro del cluster mediante un **ClusterIP**. :contentReference[oaicite:3]{index=3}

```
kind: Service
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 80
```

Esto permite que otros componentes dentro del cluster accedan al dashboard.

El uso de `ClusterIP` mantiene el servicio accesible **solo dentro del cluster**, delegando el acceso externo al recurso Ingress.

---

## Ingress

El recurso `Ingress` permite exponer el dashboard hacia el exterior del cluster. :contentReference[oaicite:4]{index=4}

El ingress es **opcional** y se controla mediante la variable:

```
ingress.enabled
```

Cuando está habilitado, se define:

- host
- path
- backend service

Esto permite integrar el dashboard con controladores de ingress como **NGINX Ingress Controller**.

---

## Uso como dependencia

El chart fue diseñado para poder ser utilizado como **dependencia dentro de un chart de nivel superior**.

Esto permite que un chart principal (por ejemplo `fox-jokes-stack`) pueda:

- desplegar gateway
- desplegar dashboard
- gestionar configuraciones compartidas

La configuración se realiza mediante `values.yaml` del chart padre.

Este enfoque permite mantener una arquitectura **modular y reutilizable** dentro de Kubernetes.

---

# fox-jokes-gateway

Este chart despliega el **gateway Nginx** dentro de Kubernetes.

El gateway es el componente encargado de **intermediar entre el frontend y las APIs externas**, centralizando el acceso a servicios externos.

Este chart fue diseñado para poder desplegarse de forma independiente o ser utilizado como **dependencia dentro de un chart de nivel superior**, como `fox-jokes-stack`.

Estructura:

```
fox-jokes-gateway
├── Chart.yaml
├── values.yaml
└── templates
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── _helpers.tpl
```

El chart define los recursos necesarios para ejecutar el gateway dentro del cluster:

- Deployment
- Service
- Ingress

---

## Chart.yaml

El archivo `Chart.yaml` define la metadata del chart. :contentReference[oaicite:0]{index=0}

```
apiVersion: v2
name: fox-jokes-gateway
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.16.0"
```

Puntos importantes:

- **type: application** indica que el chart despliega recursos dentro del cluster.
- **version** representa la versión del chart.
- **appVersion** representa la versión de la aplicación desplegada.

Este chart puede utilizarse directamente o como dependencia de un chart de mayor nivel.

---

## values.yaml

El archivo `values.yaml` define las variables configurables del chart. :contentReference[oaicite:1]{index=1}

Variables principales:

```
replicaCount:

image:
  repository:
  tag:
  pullPolicy:

service:
  type:
  port:
  clusterIP:

containerPort:

ingress:
  enabled:
  host:
  path:
```

Esto permite configurar el despliegue sin modificar los templates.

Ejemplos de configuraciones posibles:

- definir repositorio de imagen
- seleccionar tag de contenedor
- configurar tipo de servicio
- habilitar o deshabilitar ingress
- definir host y path de acceso

Esto permite que el chart sea reutilizado dentro de otros charts mediante valores heredados.

---

## Deployment

El `Deployment` define el contenedor que ejecuta el gateway. :contentReference[oaicite:2]{index=2}

El contenedor utiliza la imagen definida en `values.yaml`.

```
containers:
  - name: dashboard
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

Esto permite desplegar distintas versiones del gateway simplemente cambiando el tag de la imagen.

El número de réplicas también puede configurarse desde `values.yaml`.

---

## Service

El `Service` expone el gateway dentro del cluster. :contentReference[oaicite:3]{index=3}

```
kind: Service
spec:
  type: ClusterIP
  clusterIP: None
  ports:
    - port: 80
      targetPort: 80
```

El gateway utiliza un **ClusterIP interno**, lo que permite que otros servicios dentro del cluster puedan comunicarse con él.

El acceso externo normalmente se gestiona mediante un recurso **Ingress**.

---

## Ingress

El recurso `Ingress` permite exponer el gateway fuera del cluster. :contentReference[oaicite:4]{index=4}

El ingress es opcional y se controla mediante la variable:

```
ingress.enabled
```

Cuando está habilitado se configura:

- host
- path
- backend service

Esto permite integrar el gateway con controladores como **NGINX Ingress Controller**.

---

## Uso como dependencia

El chart fue diseñado para ser utilizado como **dependencia dentro de un stack Helm**.

Esto permite que un chart de nivel superior controle el despliegue completo de la aplicación.

Un stack puede incluir:

- fox-jokes-gateway
- fox-jokes-dashboard

y administrar configuraciones comunes como:

- repositorios de imágenes
- ingress
- namespaces
- imagePullSecrets

Este enfoque permite mantener una arquitectura **modular y reutilizable** dentro de Kubernetes.

---

# fox-jokes-stack

Este chart define el **stack completo de la aplicación** dentro de Kubernetes.

Su función es orquestar el despliegue conjunto de los componentes:

- `fox-jokes-dashboard`
- `fox-jokes-gateway`

El stack utiliza estos charts como **dependencias**, lo que permite desplegar toda la aplicación con un solo comando Helm.

Estructura:

```
fox-jokes-stack
├── Chart.yaml
├── values.yaml
└── templates
    ├── namespace.yaml
    └── secret.yaml
```

Este chart no define directamente deployments de aplicación.  
En su lugar, **coordina los charts hijos** que contienen los recursos del dashboard y del gateway.

---

## Chart.yaml

El archivo `Chart.yaml` define el stack y las dependencias que lo componen. :contentReference[oaicite:0]{index=0}

```
apiVersion: v2
name: fox-jokes-stack
description: Fox jokes
type: application
version: 0.1.0

dependencies:
  - name: fox-jokes-dashboard
    version: 0.1.0
    repository: "file://../fox-jokes-dashboard"
  - name: fox-jokes-gateway
    version: 0.1.0
    repository: "file://../fox-jokes-gateway"
```

Esto permite que Helm descargue e instale automáticamente los charts dependientes cuando se despliega el stack.

---

## values.yaml

El archivo `values.yaml` centraliza la configuración del stack completo. :contentReference[oaicite:1]{index=1}

Variables principales:

```
namespace: fox-jokes

dockerhub:
  username:
  password:

global:
  imagePullSecrets:
    name: dockerhub-secret
```

Este archivo también define la configuración específica para cada sub-chart:

### Configuración del dashboard

```
fox-jokes-dashboard:
  namespace: fox-jokes
  replicaCount: 1
  image:
    repository: alejomena99/fox-jokes-dashboard
    tag: latest
```

También se define la variable de entorno que permite que el dashboard conozca la dirección del gateway.

```
env:
  API_URL: "http://gateway.local"
```

### Configuración del gateway

```
fox-jokes-gateway:
  namespace: fox-jokes
  replicaCount: 1
  image:
    repository: alejomena99/fox-jokes-gateway
    tag: latest
```

Ambos servicios se exponen mediante ingress utilizando dominios locales:

- `dashboard.local`
- `gateway.local`

---

## Recursos adicionales del stack

El stack define recursos adicionales necesarios para el despliegue.

### Namespace

El archivo `namespace.yaml` crea el namespace donde se desplegarán todos los componentes. :contentReference[oaicite:2]{index=2}

```
kind: Namespace
metadata:
  name: {{ .Values.namespace }}
```

Esto permite aislar los recursos de la aplicación dentro del cluster.

---

### Secret de Docker Hub

El archivo `secret.yaml` crea un `imagePullSecret` para poder descargar imágenes privadas desde Docker Hub. :contentReference[oaicite:3]{index=3}

```
type: kubernetes.io/dockerconfigjson
```

Las credenciales se toman desde `values.yaml`.

Este secret es utilizado por los deployments para autenticarse contra el registro de Docker.

---

# Despliegue del stack en Minikube

El stack puede desplegarse fácilmente en un cluster local utilizando **Minikube**.

## 1. Iniciar Minikube

```
minikube start --driver=docker --memory=4g --cpus=2
```

Esto crea un cluster Kubernetes local utilizando Docker como driver.

---

## 2. Habilitar Ingress

```
minikube addons enable ingress
```

Esto instala el **NGINX Ingress Controller** dentro del cluster.

---

## 3. Actualizar dependencias del chart

Antes de instalar el stack se deben descargar los charts dependientes.

```
helm dependency update
```

Esto descargará los charts:

- fox-jokes-dashboard
- fox-jokes-gateway

---

## 4. Desplegar el stack

```
helm upgrade --install fox-jokes .
```

Este comando:

- instala el stack si no existe
- actualiza la instalación si ya está desplegada

---

## 5. Configurar dominios locales

El ingress del stack utiliza dominios locales.

Para que el sistema pueda resolverlos se deben agregar al archivo `/etc/hosts`.

```
echo "$(minikube ip) gateway.local" | sudo tee -a /etc/hosts
echo "$(minikube ip) dashboard.local" | sudo tee -a /etc/hosts
```

Esto permitirá acceder a los servicios desde el navegador.

---

## 6. Acceso a la aplicación

Una vez desplegado el stack:

Gateway:

```
http://gateway.local
```

Dashboard:

```
http://dashboard.local
```

---

# Documentación de Minikube

Para más información sobre Minikube y su configuración:

https://minikube.sigs.k8s.io/docs/