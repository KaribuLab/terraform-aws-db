output "db_writer_endpoint" {
  value = aws_rds_cluster_instance.db.endpoint
}

output "db_database_name" {
  value = aws_rds_cluster.db.database_name
}

output "db_admin_user" {
  value = aws_rds_cluster.db.master_username
}

output "db_port" {
  value = aws_rds_cluster.db.port
}

output "db_admin_password" {
  value     = random_password.db.result
  sensitive = true
}
