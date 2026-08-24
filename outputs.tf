output "cloudfront_url" {
  description = "Öffentliche HTTPS-Adresse des Dashboards."
  value       = "https://${aws_cloudfront_distribution.dashboard.domain_name}"
}

output "latest_json_url" {
  description = "Öffentliche URL der jeweils letzten Tagesausgabe über CloudFront."
  value       = "https://${aws_cloudfront_distribution.dashboard.domain_name}/data/latest.json"
}

output "frontend_bucket" {
  description = "Name des privaten Frontend-Buckets."
  value       = aws_s3_bucket.frontend.bucket
}

output "data_bucket" {
  description = "Name des privaten Daten-Buckets."
  value       = aws_s3_bucket.data.bucket
}

output "lambda_function_name" {
  description = "Name der Verarbeitungsfunktion."
  value       = aws_lambda_function.processor.function_name
}

output "scheduler_name" {
  description = "Name des täglichen EventBridge-Schedulers."
  value       = aws_scheduler_schedule.daily.name
}

output "bedrock_inference_profile_arn" {
  description = "Von AWS verwaltetes EU-Inferenzprofil für Nova Micro."
  value       = data.aws_bedrock_inference_profile.nova_micro_eu.inference_profile_arn
}
