# Arquitectura del Desafío 2

El desafío 2 implementa **infraestructura como código (IaC)** utilizando **OpenTofu / Terraform** para desplegar una **Virtual Private Cloud (VPC)** en AWS.

La infraestructura definida crea una red preparada para alojar servicios cloud en entornos productivos.

Estructura del desafío:

```
desafio_2
├── diagrams
│   └── VPC-Diagram.drawio.svg
│
└── terraform-opentofu
    ├── backend.tf
    ├── backend.tfvars
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── terraform.tfvars
    └── variables.tf
```

La solución se divide en dos partes principales:

- **diagrams** → documentación visual de la infraestructura
- **terraform-opentofu** → definición de infraestructura como código

---

# Arquitectura de Infraestructura (`diagrams`)

La carpeta `diagrams` contiene el archivo:

```
VPC-Diagram.drawio.svg
```

Este diagrama describe la arquitectura de red desplegada en AWS.

![VPC Architecture](./diagrams/VPC-Diagram.drawio.svg)

La infraestructura implementa los siguientes componentes:

- **1 VPC**
- **3 subnets públicas**
- **3 subnets privadas**
- **1 Internet Gateway**
- **tablas de rutas para segmentación de tráfico**

### VPC

La VPC es la red principal que contiene todos los recursos de infraestructura.

Permite definir rangos de IP privados y aislar los recursos desplegados dentro de AWS.

### Subnets públicas

Las subnets públicas están conectadas al **Internet Gateway**.

Estas subnets están diseñadas para alojar recursos que requieren acceso directo a internet, como:

- Load Balancers
- Gateways
- Servicios expuestos públicamente

### Subnets privadas

Las subnets privadas están aisladas del acceso directo a internet.

Estas subnets están diseñadas para alojar recursos internos como:

- contenedores
- servicios backend
- bases de datos

Esta separación permite aplicar mejores prácticas de seguridad en arquitecturas cloud.

---

# Infraestructura como Código (`terraform-opentofu`)

La carpeta `terraform-opentofu` contiene la definición completa de la infraestructura utilizando **OpenTofu**, una alternativa open-source compatible con Terraform.

Archivos principales:

```
terraform-opentofu
├── backend.tf
├── backend.tfvars
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf
```

### provider.tf

Define el proveedor de infraestructura utilizado.

En este caso se utiliza **AWS** como proveedor cloud y se define la región donde se desplegarán los recursos.

---

### variables.tf

Define las variables utilizadas por la infraestructura.

Esto permite parametrizar la configuración del despliegue, por ejemplo:

- rangos CIDR
- nombres de recursos
- configuración de red

---

### terraform.tfvars

Contiene los valores concretos de las variables definidas.

Esto permite mantener separada la definición de infraestructura de la configuración específica del entorno.

---

### main.tf

Define los recursos principales de infraestructura.

Entre ellos:

- VPC
- subnets públicas
- subnets privadas
- Internet Gateway
- tablas de rutas

Este archivo representa la definición central de la red desplegada en AWS.

---

### outputs.tf

Define las salidas generadas después de aplicar la infraestructura.

Estas salidas permiten obtener información útil como:

- ID de la VPC
- IDs de las subnets

Estos valores podrán ser utilizados posteriormente en el **Desafío 3**.

---

### backend.tf

Define el **backend remoto** utilizado para almacenar el estado de Terraform.

En este caso se utiliza **Amazon S3** para guardar el estado de la infraestructura.

Esto permite:

- mantener el estado persistente
- evitar conflictos entre ejecuciones
- facilitar despliegues colaborativos

---

# Preparación del Backend de Estado

Antes de ejecutar OpenTofu es necesario crear el bucket S3 que almacenará el estado de la infraestructura.

Primero se deben configurar las credenciales de AWS.

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

Luego se crea el bucket que almacenará el estado.

```
aws s3api create-bucket \
  --bucket carvajal-tfstate-s3 \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2
```

Este bucket será utilizado por Terraform/OpenTofu para almacenar el archivo de estado remoto.

---

# Inicialización y despliegue de la infraestructura

Una vez configurado el backend se puede inicializar y desplegar la infraestructura.

### Inicializar el proyecto

```
tofu init -backend-config="backend.tfvars"
```

Este comando:

- descarga proveedores
- configura el backend remoto
- prepara el entorno de ejecución

---

### Validar configuración

```
tofu validate
```

Verifica que la definición de infraestructura sea válida.

---

### Generar plan de ejecución

```
tofu plan -var-file="terraform.tfvars"
```

Muestra los recursos que serán creados o modificados.

---

### Aplicar infraestructura

```
tofu apply -var-file="terraform.tfvars"
```

Este comando crea los recursos definidos en AWS.

---

# Resultado

Al finalizar la ejecución se habrá desplegado una **VPC completa con segmentación de red** preparada para alojar aplicaciones cloud.

Esta infraestructura será utilizada posteriormente en el **Desafío 3** para desplegar servicios dentro de las subnets privadas.