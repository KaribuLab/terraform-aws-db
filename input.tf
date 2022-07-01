variable "customer_prefix" {
  type = string
}

variable "environment_suffix" {
  type = string
}

variable "network" {
  type = object({
    vpc_id          = string
    vpc_cidr_blocks = list(string)
    subnet_ids      = list(string)
    ingress_ips     = list(string)
  })
}

variable "cluster" {
  type = object({
    instance_class      = string
    name                = string
    user                = string
    port                = string
    engine              = string
    engine_version      = string
    min_capacity        = number
    max_capacity        = number
    deletion_protection = bool
    publicly_accessible = bool
    availability_zones  = list(string)
  })
}

variable "common_tags" {
  type = map(any)
}
