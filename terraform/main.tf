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
  minio_server = "localhost:9000"
  minio_user   = "username"
  minio_password = "password"
}

# Create buckets
resource "minio_s3_bucket" "ota" {
  bucket = "ota"
  acl    = "public"
  force_destroy = true
}

resource "minio_s3_bucket" "graphs" {
  bucket = "graphs"
  acl    = "private"
  force_destroy = true
}

resource "minio_s3_bucket" "avatars" {
  bucket = "avatars"
  acl    = "public"
  force_destroy = true
}

resource "minio_s3_bucket" "images" {
  bucket = "images"
  acl    = "public"
  force_destroy = true
}

resource "minio_s3_bucket" "static" {
  bucket = "static"
  acl    = "public"
  force_destroy = true
}

#TODO move to bucket policies
resource "minio_s3_bucket_policy" "static_policy" {
  bucket = minio_s3_bucket.static.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject", "s3:ListBucket"]
        Resource  = [
          "arn:aws:s3:::${minio_s3_bucket.static.bucket}/*",
          "arn:aws:s3:::${minio_s3_bucket.static.bucket}"
        ]
      },
      {
        Sid    = "AllowWrite"
        Effect = "Allow"
        Principal = {
          AWS = ["*"]  # W produkcji należy to ograniczyć
        }
        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${minio_s3_bucket.static.bucket}/*"
        ]
      }
    ]
  })
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

locals {
  build_path = "${path.module}/build"
  # Verify build directory exists
  build_dir_check = fileexists("${local.build_path}/index.html") ? null : file("ERROR: Build directory not found or empty")
}


resource "minio_s3_object" "frontend_files" {
  for_each = {
    for file in fileset(local.build_path, "**/*") :
    file => file
    if fileexists("${local.build_path}/${file}")
  }
  
  bucket_name  = minio_s3_bucket.static.bucket
  object_name  = each.value
  #TODO quickfix change to source when find solution to terraform putting object failed (): one of source / content / content_base64 is not set
  content       = file("${local.build_path}/${each.value}")
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
  etag = filemd5("${local.build_path}/${each.value}")

  depends_on = [
    minio_s3_bucket.static,
    minio_s3_bucket_policy.static_policy
  ]
}