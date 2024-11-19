output "mlflow_endpoint" {
  description = "MLflow server endpoint"
  value       = "https://${aws_lb.mlflow.dns_name}"
}

output "mlflow_db_endpoint" {
  description = "MLflow database endpoint"
  value       = aws_db_instance.mlflow.endpoint
}

output "mlflow_bucket" {
  description = "MLflow S3 bucket name"
  value       = aws_s3_bucket.mlflow.id
}