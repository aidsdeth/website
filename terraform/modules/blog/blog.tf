# S3 Bucket Configuration

resource "aws_s3_bucket" "blogdomain" {
  bucket = var.blogdomain
}