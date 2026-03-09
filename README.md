# DevOps Challenge – Carvajal Digital

Este repositorio contiene la solución al **Desafío Práctico de Implementación DevOps**, el cual consiste en construir una aplicación que consuma APIs públicas, empaquetarla en Docker y desplegarla en una infraestructura en AWS definida como código utilizando Terraform.

La solución está dividida en **tres desafíos principales**, cada uno ubicado en su propio directorio dentro del repositorio.

---

# Estructura del repositorio

El proyecto está organizado de la siguiente forma:

```bash
.
├── desafio_1
├── desafio_2
└── desafio_3
```

Cada carpeta corresponde a una etapa específica del desafío.

---

# Desafío 1 – Aplicación + Docker + Scripts

Este desafío implementa una aplicación web que consume dos APIs públicas:

- **JokeAPI** → para obtener chistes de programación.
- **RandomFox API** → para obtener imágenes aleatorias de zorros.

La aplicación muestra esta información en un **dashboard web con dos tarjetas**.

Además, se implementa:

- Construcción de una **imagen Docker**
- Publicación en **Docker Hub**
- Script para **descargar y ejecutar la imagen localmente**

## Estructura

```bash
desafio_1
│
├── apps
│ ├── fox_jokes_dashboard
│ └── fox_jokes_gateway
│
├── helm
│
└── scripts
├── build_and_push.sh
└── pull_and_run.sh
```


### fox_jokes_dashboard

Aplicación frontend construida con **Vue.js + Vite** que consume las APIs externas y muestra la información en un dashboard.

Componentes principales:

- `JokeCard.vue` → muestra un chiste de programación
- `FoxCard.vue` → muestra una imagen aleatoria de un zorro
- `Dashboard.vue` → layout principal del dashboard

### fox_jokes_gateway

Contenedor basado en **Nginx** que funciona como gateway para servir la aplicación web.

### scripts

Contiene los scripts necesarios para automatizar el ciclo de vida del contenedor:

- `build_and_push.sh`
  - Construye la imagen Docker
  - La publica en Docker Hub

- `pull_and_run.sh`
  - Descarga la imagen desde Docker Hub
  - Ejecuta el contenedor localmente

### helm

Incluye charts de **Helm** que permiten desplegar la aplicación en un cluster de Kubernetes de forma declarativa.

Para más información sobre la implementación de este desafío, consulta el README específico: [desafio_1/README.md](./desafio_1/README.md)

---

# Desafío 2 – Infraestructura de Red con Terraform

Este desafío implementa una **Virtual Private Cloud (VPC)** en AWS utilizando Terraform.

La arquitectura de red incluye:

- 1 VPC
- 3 subnets públicas
- 3 subnets privadas
- 1 Internet Gateway
- configuraciones de enrutamiento necesarias

## Estructura

```bash
desafio_2
│
├── diagrams
│ └── VPC-Diagram.drawio.svg
│
└── terraform-opentofu
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
└── terraform.tfvars
```

También se incluye un **diagrama de arquitectura generado con Draw.io** que describe la topología de la red.

Para más información sobre la implementación de este desafío, consulta el README específico: [desafio_2/README.md](./desafio_2/README.md)

---

# Desafío 3 – Despliegue en Alta Disponibilidad

Este desafío integra los anteriores.

Se despliega la aplicación Docker creada en el **Desafío 1** dentro de la infraestructura creada en el **Desafío 2**, utilizando Terraform.

La arquitectura incluye:

- **AWS ECS con Fargate**
- **Application Load Balancer**
- Contenedores ejecutándose en **subnets privadas**
- Balanceo de tráfico desde subnets públicas

## Estructura

```bash
desafio_3
│
└── terraform-opentofu
├── modules
│ ├── alb
│ ├── ecs_fargate
│ └── nat_gateway
│
├── main.tf
├── data.tf
├── variables.tf
└── outputs.tf
```


Se utilizan **módulos de Terraform** para mantener el código organizado y reutilizable.

---

# Tecnologías utilizadas

- **Vue.js**
- **Vite**
- **Docker**
- **Docker Hub**
- **Nginx**
- **Terraform / OpenTofu**
- **AWS**
- **Helm**
- **Bash scripting**

---

# Arquitectura general

La solución completa sigue el siguiente flujo:

1. La aplicación web consume APIs externas:
   - JokeAPI
   - RandomFox API

2. La aplicación se empaqueta en una **imagen Docker**.

3. La imagen se publica en **Docker Hub**.

4. Terraform despliega infraestructura en AWS:

   - VPC
   - subnets públicas y privadas
   - ECS Fargate
   - Application Load Balancer

5. El **ALB expone la aplicación al internet**, mientras que los contenedores se ejecutan en **subredes privadas**.

Para más información sobre la implementación de este desafío, consulta el README específico: [desafio_3/README.md](./desafio_3/README.md)

---