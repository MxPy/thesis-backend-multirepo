# main.tf
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Namespace
resource "kubernetes_namespace" "thesis" {
  metadata {
    name = var.namespace
  }
}

# Secrets
resource "kubernetes_secret" "db_secrets" {
  metadata {
    name      = "db-secrets"
    namespace = kubernetes_namespace.thesis.metadata[0].name
  }

  data = {
    "postgres-password"     = base64encode(var.postgres_password)
    "mongo-username"        = base64encode(var.mongo_username)
    "mongo-password"        = base64encode(var.mongo_password)
    "minio-root-user"      = base64encode(var.minio_root_user)
    "minio-root-password"  = base64encode(var.minio_root_password)
  }

  type = "Opaque"
}

# ConfigMap
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.thesis.metadata[0].name
  }

  data = {
    MINIO_HOST         = "minio"
    MINIO_PORT         = "9000"
    MINIO_SECURE       = "false"
    MINIO_BUCKET_NAME  = "minio-bucket"
    DATABASE_URL       = "postgresql://postgres:${var.postgres_password}@db:5433/users"
    POSTGRES_URL       = "postgres://postgres:${var.postgres_password}@db:5433/postgres"
    TIMESCALE_URL     = "postgres://postgres:${var.timescale_password}@timescaledb:5432/timescaledb"
  }
}

# Storage
module "storage" {
  source    = "./modules/storage"
  namespace = kubernetes_namespace.thesis.metadata[0].name
}

# Databases
module "databases" {
  source    = "./modules/databases"
  namespace = kubernetes_namespace.thesis.metadata[0].name
  depends_on = [
    kubernetes_secret.db_secrets,
    module.storage
  ]
}

# Services
module "services" {
  source    = "./modules/services"
  namespace = kubernetes_namespace.thesis.metadata[0].name
  depends_on = [
    module.databases
  ]
}