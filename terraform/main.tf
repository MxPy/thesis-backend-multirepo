# Provider configuration
terraform {
  required_providers {
    minio = {
      source = "aminueza/minio"
      version = "~> 1.0"
    }
  }
}

provider "minio" {
  minio_server = "minio:9000"
  minio_user   = "username"
  minio_password = "password"
}

# Create buckets
resource "minio_s3_bucket" "ota" {
  bucket = "ota"
  acl    = "public"
}

resource "minio_s3_bucket" "graphs" {
  bucket = "graphs"
  acl    = "private"
}

resource "minio_s3_bucket" "avatars" {
  bucket = "avatars"
  acl    = "public"
}

resource "minio_s3_bucket" "images" {
  bucket = "images"
  acl    = "public"
}

resource "minio_s3_bucket" "static" {
  bucket = "static"
  acl    = "public"
}

# Set bucket policies
resource "minio_s3_bucket_policy" "ota_policy" {
  bucket = minio_s3_bucket.ota.bucket
  policy = file("buckets-policy/ota.yml")
}

resource "minio_s3_bucket_policy" "avatars_policy" {
  bucket = minio_s3_bucket.avatars.bucket
  policy = file("buckets-policy/avatars.yml")
}

resource "minio_s3_bucket_policy" "images_policy" {
  bucket = minio_s3_bucket.images.bucket
  policy = file("buckets-policy/images.yml")
}

resource "minio_s3_object" "frontend_files" {
  for_each = fileset("build/", "**/*")

  bucket_name = minio_s3_bucket.static.bucket
  object_name = each.value
  content      = "build/${each.value}"
  content_type = lookup({
    ".html" = "text/html",
    ".css"  = "text/css",
    ".js"   = "application/javascript",
    ".json" = "application/json",
    ".png"  = "image/png",
    ".jpg"  = "image/jpeg",
    ".svg"  = "image/svg+xml",
    ".ico"  = "image/x-icon"
  }, regex("\\.[^.]+$", each.value), "application/octet-stream")

  etag = filemd5("build/${each.value}")
}
