output "bucket_arn" {
  value = aws_s3_bucket.artifacts_bucket.arn
}

output "bucket_name" {
  value = aws_s3_bucket.artifacts_bucket.bucket
}