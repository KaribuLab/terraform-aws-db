terraform {
  backend "s3" {}
}

resource "random_password" "db" {
  length  = 16
  special = false
}
resource "aws_db_subnet_group" "db" {
  name       = "${var.customer_prefix}_${var.cluster.name}_sng_${var.environment_suffix}"
  subnet_ids = var.network.subnet_ids
}
resource "aws_security_group" "db" {
  name   = "${var.customer_prefix}_${var.cluster.name}_sg_${var.environment_suffix}"
  vpc_id = var.network.vpc_id
  dynamic "ingress" {
    for_each = toset(var.network.ingress_ips)
    content {
      protocol    = "tcp"
      from_port   = var.cluster.port
      to_port     = var.cluster.port
      cidr_blocks = ["0.0.0.0" == ingress.key ? "${ingress.key}/0" : "${ingress.key}/32"]
    }
  }
  dynamic "ingress" {
    for_each = toset(var.network.vpc_cidr_blocks)
    content {
      protocol    = "tcp"
      from_port   = var.cluster.port
      to_port     = var.cluster.port
      cidr_blocks = [ingress.key]
    }
  }
  egress {
    protocol         = -1
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(var.common_tags, {
    Name = "${var.common_tags.customer} ${var.cluster.name} ${var.common_tags.environment}"
  })
}
resource "aws_rds_cluster" "db" {
  cluster_identifier     = "${var.customer_prefix}-${var.cluster.name}-cluster-${var.environment_suffix}"
  database_name          = "${replace(var.cluster.name, "-", "_")}_${var.environment_suffix}"
  availability_zones     = var.cluster.availability_zones
  deletion_protection    = var.cluster.deletion_protection
  db_subnet_group_name   = aws_db_subnet_group.db.name
  engine                 = var.cluster.engine
  engine_version         = var.cluster.engine_version
  master_username        = var.cluster.user
  master_password        = random_password.db.result
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true
  tags = merge(var.common_tags, {
    Name = "${var.common_tags.customer} ${var.cluster.name} ${var.common_tags.environment}"
  })
}

resource "aws_rds_cluster_instance" "db" {
  identifier           = "${var.customer_prefix}-${var.cluster.name}-instance-${var.environment_suffix}"
  cluster_identifier   = aws_rds_cluster.db.id
  instance_class       = var.cluster.instance_class
  engine               = aws_rds_cluster.db.engine
  engine_version       = aws_rds_cluster.db.engine_version
  publicly_accessible  = var.cluster.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.db.name
  tags = merge(var.common_tags, {
    Name = "${var.common_tags.customer} ${var.cluster.name} ${var.common_tags.environment}"
  })
}

resource "aws_appautoscaling_target" "db" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.db.id}"
  min_capacity       = var.cluster.min_capacity
  max_capacity       = var.cluster.max_capacity
}

resource "aws_appautoscaling_policy" "db" {
  name               = "cpu-auto-scaling"
  service_namespace  = aws_appautoscaling_target.db.service_namespace
  scalable_dimension = aws_appautoscaling_target.db.scalable_dimension
  resource_id        = aws_appautoscaling_target.db.resource_id
  policy_type        = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }
    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_ssm_parameter" "db" {
  name = "/${var.customer_prefix}/${var.environment_suffix}/db/${aws_rds_cluster.db.database_name}"
  type = "String"
  tier = "Advanced"
  value = jsonencode({
    admin_password        = random_password.db.result
    admin_user            = aws_rds_cluster.db.master_username
    admin_database_name   = aws_rds_cluster.db.database_name
    admin_writer_endpoint = aws_rds_cluster_instance.db.endpoint
    admin_writer_port     = aws_rds_cluster_instance.db.port
  })
  tags = var.common_tags
}
