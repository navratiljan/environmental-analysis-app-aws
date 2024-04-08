output "s3_bucket_id" {
  value       = aws_s3_bucket.alb_logs.id
  description = "this outputs bucket id"
}