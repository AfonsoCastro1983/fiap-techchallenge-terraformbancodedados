# Outputs
output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
  description = "RDS endpoint"
}