# modules/databases/main.tf
# PostgreSQL
variable "namespace" {
  type = string
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:latest"

          port {
            container_port = 5433
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "db-secrets"
                key  = "postgres-password"
              }
            }
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }

          liveness_probe {
            exec {
              command = ["pg_isready"]
            }
            initial_delay_seconds = 30
            period_seconds       = 10
          }
        }

        volume {
          name = "postgres-data"
          persistent_volume_claim {
            claim_name = "postgres-data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "db"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5433
      target_port = 5433
    }

    cluster_ip = "None"
  }
}


# RabbitMQ
resource "kubernetes_deployment" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "rabbitmq"
      }
    }
    template {
      metadata {
        labels = {
          app = "rabbitmq"
        }
      }
      spec {
        container {
          name              = "rabbitmq"
          image            = "rabbitmq:3.11.8-management-alpine"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5672
          }
          port {
            container_port = 15672
          }
          liveness_probe {
            exec {
              command = ["rabbitmq-diagnostics", "-q", "ping"]
            }
            initial_delay_seconds = 30
            period_seconds       = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "rabbitmq"
    }
    port {
      name        = "amqp"
      port        = 5672
      target_port = 5672
    }
    port {
      name        = "management"
      port        = 15672
      target_port = 15672
    }
    type = "ClusterIP"
  }
}

# MongoDB
resource "kubernetes_deployment" "mongo" {
  metadata {
    name      = "mongo"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mongo"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }
      spec {
        container {
          name              = "mongo"
          image            = "mongo:latest"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 27017
          }
          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = "Username"
          }
          env {
            name  = "MONGO_INITDB_ROOT_PASSWORD"
            value = "Password"
          }
          env {
            name  = "MONGO_INITDB_DATABASE"
            value = "sessions"
          }
          volume_mount {
            name       = "mongo-data"
            mount_path = "/data/db"
          }
          volume_mount {
            name       = "mongo-init"
            mount_path = "/docker-entrypoint-initdb.d"
            read_only  = true
          }
        }
        volume {
          name = "mongo-data"
          persistent_volume_claim {
            claim_name = "mongo-pvc"
          }
        }
        volume {
          name = "mongo-init"
          config_map {
            name = "mongo-init"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mongo" {
  metadata {
    name      = "mongo"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "mongo"
    }
    port {
      port        = 27017
      target_port = 27017
    }
    type = "ClusterIP"
  }
}

# TimescaleDB
resource "kubernetes_deployment" "timescaledb" {
  metadata {
    name      = "timescaledb"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "timescaledb"
      }
    }
    template {
      metadata {
        labels = {
          app = "timescaledb"
        }
      }
      spec {
        container {
          name              = "timescaledb"
          image            = "timescale/timescaledb:latest-pg16"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5432
          }
          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = "pass"
          }
          env {
            name  = "POSTGRES_DB"
            value = "timescaledb"
          }
          volume_mount {
            name       = "timescale-data"
            mount_path = "/var/lib/postgresql/data"
          }
          liveness_probe {
            exec {
              command = ["pg_isready", "-U", "postgres"]
            }
            initial_delay_seconds = 30
            period_seconds       = 10
          }
        }
        volume {
          name = "timescale-data"
          persistent_volume_claim {
            claim_name = "timescale-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "timescaledb" {
  metadata {
    name      = "timescaledb"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "timescaledb"
    }
    port {
      port        = 5432
      target_port = 5432
    }
    type = "ClusterIP"
  }
}
