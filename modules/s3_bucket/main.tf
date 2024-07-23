resource "aws_s3_bucket" "this" {
  bucket = var.bucket
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}
