# Arquitectura del Desafío 3

El desafío 3 extiende la infraestructura creada en el **Desafío 2** para desplegar una aplicación containerizada en AWS utilizando **ECS Fargate** detrás de un **Application Load Balancer (ALB)**.

La infraestructura está definida utilizando **OpenTofu / Terraform** y sigue una arquitectura modular basada en módulos reutilizables.

Estructura del desafío:

```
desafio_3
├── diagrams
│   └── VPC-Diagram.drawio-plus.svg
│
└── terraform-opentofu
    ├── backend.tf
    ├── backend.tfvars
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── terraform.tfvars
    ├── variables.tf
    │
    └── modules
        ├── alb
        ├── ecs_fargate
        └── nat_gateway
```

La solución se divide en dos partes principales:

- **diagrams** → arquitectura de la infraestructura desplegada
- **terraform-opentofu** → definición modular de infraestructura como código

---

# Arquitectura de Infraestructura (`diagrams`)

La carpeta `diagrams` contiene el archivo:

```
VPC-Diagram.drawio-plus.svg
```

Este diagrama describe la arquitectura completa desplegada en AWS.

![Architecture](./diagrams/VPC-Diagram.drawio-plus.svg)

La arquitectura incluye los siguientes componentes:

- VPC creada en el **Desafío 2**
- subnets públicas
- subnets privadas
- Internet Gateway
- NAT Gateway
- Application Load Balancer
- ECS Fargate Service

Flujo de tráfico:

```
Internet
   │
   ▼
Application Load Balancer
   │
   ▼
ECS Fargate Service
   │
   ▼
Private Subnets
```

El **ALB** recibe tráfico HTTP desde internet y lo redirige hacia los contenedores ejecutándose en ECS Fargate.

---

# Infraestructura como Código (`terraform-opentofu`)

La infraestructura está definida utilizando **OpenTofu** con una arquitectura basada en módulos.

Archivos principales:

```
terraform-opentofu
├── backend.tf
├── backend.tfvars
├── data.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf
```

Además se utilizan **módulos reutilizables** para encapsular componentes de infraestructura.

```
modules
├── alb
├── ecs_fargate
└── nat_gateway
```

Esto permite separar responsabilidades y mantener la infraestructura organizada.

---

# Módulo ALB

El módulo `alb` crea el **Application Load Balancer** que expone la aplicación hacia internet.

Componentes creados:

- Security Group del ALB
- Application Load Balancer
- Target Group
- Listener HTTP

El security group permite tráfico HTTP desde internet.

```
ingress {
  from_port   = var.alb_port
  to_port     = var.alb_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

El ALB se despliega en **subnets públicas** y enruta el tráfico hacia el Target Group asociado al servicio ECS.

El Target Group realiza **health checks** sobre los contenedores desplegados.

---

# Módulo ECS Fargate

El módulo `ecs_fargate` despliega la aplicación utilizando **Amazon ECS con Fargate**.

Componentes creados:

- IAM Role para ejecución de tareas
- Security Group para ECS
- ECS Cluster
- ECS Task Definition
- ECS Service

Los contenedores se ejecutan dentro de **subnets privadas** para mejorar la seguridad.

El acceso a los contenedores está restringido únicamente al ALB.

```
ingress {
  from_port       = var.container_port
  to_port         = var.container_port
  protocol        = "tcp"
  security_groups = [var.alb_sg_id]
}
```

Esto evita que los contenedores estén expuestos directamente a internet.

El servicio ECS se conecta al **Target Group del ALB**, permitiendo balanceo de carga entre instancias.

---

# NAT Gateway

El módulo `nat_gateway` crea un **NAT Gateway** dentro de una subnet pública.

Componentes creados:

- Elastic IP
- NAT Gateway
- ruta desde subnets privadas hacia el NAT

Este componente **no estaba explícitamente solicitado en el desafío**, pero fue necesario para que los contenedores ejecutándose en ECS Fargate puedan acceder a internet.

Los contenedores necesitan acceso externo para poder:

- descargar imágenes desde **Docker Hub**
- comunicarse con servicios externos

Sin NAT Gateway, los contenedores en subnets privadas no podrían realizar estas operaciones.

Flujo de salida:

```
Private Subnet
   │
   ▼
NAT Gateway
   │
   ▼
Internet
```

Esto permite mantener los contenedores en una red privada mientras conservan acceso saliente controlado.

---

# Preparación del Backend de Estado

Al igual que en el desafío anterior, se utiliza **Amazon S3 como backend remoto** para almacenar el estado de OpenTofu.

Primero se deben configurar las credenciales de AWS.

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

Luego se debe crear el bucket para almacenar el estado (si aún no existe).

```
aws s3api create-bucket \
  --bucket carvajal-tfstate-s3 \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2
```

Es posible que este bucket ya exista si fue creado durante el **Desafío 2**.

---

# Inicialización y despliegue de la infraestructura

Una vez configurado el backend se puede inicializar el proyecto.

### Inicializar OpenTofu

```
tofu init -backend-config="backend.tfvars"
```

Este comando descarga proveedores y configura el backend remoto.

---

### Generar plan de infraestructura

```
tofu plan -var-file="terraform.tfvars"
```

Muestra los recursos que serán creados.

---

### Aplicar infraestructura

```
tofu apply -var-file="terraform.tfvars"
```

Esto desplegará:

- Application Load Balancer
- ECS Cluster
- ECS Fargate Service
- NAT Gateway
- configuraciones de red

---

# Resultado

Al finalizar el despliegue se obtiene una arquitectura cloud completa compuesta por:

- Application Load Balancer público
- servicio ECS Fargate ejecutando contenedores
- subnets privadas para los servicios
- NAT Gateway para acceso saliente
- balanceo de carga y health checks automáticos

Esta arquitectura sigue buenas prácticas de infraestructura cloud:

- **servicios backend en subnets privadas**
- **balanceo de carga mediante ALB**
- **control de acceso mediante security groups**
- **acceso saliente controlado mediante NAT Gateway**

El resultado es una infraestructura preparada para ejecutar aplicaciones containerizadas de forma segura y escalable en AWS.