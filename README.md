# Terraform AWS DB

Módulo que permite crear un cluster de BD con cualquier motor de RDS

## Variables

| Nombre              | Descripción                                                                                       |
| ------------------- | ------------------------------------------------------------------------------------------------- |
| customer_prefix     | Prefijo del cliente que será parte del nombre del recurso                                         |
| environment_suffix  | Sufijo del ambiente que será parte del nombre del recurso                                         |
| common_tags         | Tags que serán parte del recurso                                                                  |
| [network](#network) | Objeto que contiene datos de la VPC. subred y lista IP usadas en reglas de entrada security group |
| [cluster](#cluster) | Objeto que contiene datos del cluster tales como motor, tipo de instancia, etc.                   |

### network

| Nombre          | Descripción                                                 |
| --------------- | ----------------------------------------------------------- |
| vpc_id          | ID de la VPC donde estará la BD                             |
| vpc_cidr_blocks | Bloques CIDR de la VPC usado para grupo de seguridad        |
| subnet_ids      | ID de las subredes donde se distribuirá el cluster de la BD |
| ingress_ips     | IP que tendrán acceso a través de grupo de seguridad        |

### cluster

| Nombre              | Descripción                                                  |
| ------------------- | ------------------------------------------------------------ |
| instance_class      | Clase de la instancia de RDS                                 |
| name                | Nombre utilizado para la BD y el cluster                     |
| user                | Nombre de usuario administrador de la BD                     |
| port                | Puerto de la BD                                              |
| engine              | Motor de BD RDS                                              |
| engine_version      | Versión del Motor de BD RDS                                  |
| min_capacity        | Cantidad mínima de instancias del cluster                    |
| max_capacity        | Cantidad máxima de instancias del cluster                    |
| deletion_protection | Indica si el cluster debe tener protección de borrado        |
| publicly_accessible | Indica si el cluster es accedido desde internet              |
| availability_zones  | Zonas de disponibilidad en las que se distribuirá el cluster |