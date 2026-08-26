# Zwei getrennte private Buckets: einer für das Frontend, einer für die erzeugten JSON-Daten.
resource "aws_s3_bucket" "frontend" {
  bucket        = local.frontend_bucket_name
  force_destroy = var.force_destroy_buckets
}

resource "aws_s3_bucket" "data" {
  bucket        = local.data_bucket_name
  force_destroy = var.force_destroy_buckets
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Explizite serverseitige Verschlüsselung mit von S3 verwalteten Schlüsseln (SSE-S3).
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Nur datierte Archivdateien werden nach 14 Tagen entfernt; data/latest.json bleibt bestehen.
resource "aws_s3_bucket_lifecycle_configuration" "data_archive" {
  bucket = aws_s3_bucket.data.id

  rule {
    id     = "expire-daily-archive"
    status = "Enabled"

    filter {
      prefix = local.archive_prefix
    }

    expiration {
      days = var.archive_retention_days
    }
  }
}

# Das responsive Dashboard wird als statische HTML-Datei im privaten Frontend-Bucket bereitgestellt.
resource "aws_s3_object" "frontend_index" {
  bucket        = aws_s3_bucket.frontend.id
  key           = "index.html"
  source        = "${path.module}/frontend/index.html"
  etag          = filemd5("${path.module}/frontend/index.html")
  content_type  = "text/html; charset=utf-8"
  cache_control = "max-age=300"

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.frontend,
    aws_s3_bucket_public_access_block.frontend
  ]
}
