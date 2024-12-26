# modules/services/main.tf
# Gateway
variable "namespace" {
  type = string
}

resource "kubernetes_deployment" "gateway" {
  metadata {
    name      = "gateway"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gateway"
      }
    }

    template {
      metadata {
        labels = {
          app = "gateway"
        }
      }

      spec {
        container {
          name              = "gateway"
          image            = "thesis-prototype-apigateway:latest"
          image_pull_policy = "Never"

          port {
            container_port = 8000
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds       = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "gateway" {
  metadata {
    name      = "gateway"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "gateway"
    }

    port {
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }
}

# Users Service
resource "kubernetes_deployment" "users" {
  metadata {
    name      = "users"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "users"
      }
    }
    template {
      metadata {
        labels = {
          app = "users"
        }
      }
      spec {
        container {
          name              = "users"
          image            = "thesis-prototype-server:latest"
          image_pull_policy = "Never"
          port {
            container_port = 8000
          }
          port {
            container_port = 50051
          }
          env {
            name  = "DATABASE_URL"
            value = "postgresql://postgres:mysecretpassword@db/users"
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds       = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "users" {
  metadata {
    name      = "users"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "users"
    }
    port {
      name        = "http"
      port        = 8000
      target_port = 8000
    }
    port {
      name        = "grpc"
      port        = 50051
      target_port = 50051
    }
    type = "ClusterIP"
  }
}

# App Postgres Wrapper
resource "kubernetes_deployment" "app_postgres_wrapper" {
  metadata {
    name      = "app-postgres-wrapper"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "app-postgres-wrapper"
      }
    }
    template {
      metadata {
        labels = {
          app = "app-postgres-wrapper"
        }
      }
      spec {
        container {
          name              = "app-postgres-wrapper"
          image            = "thesis-health-wrapper:latest"
          image_pull_policy = "Never"
          port {
            container_port = 50053
          }
          env {
            name  = "POSTGRES_URL"
            value = "postgres://postgres:mysecretpassword@db:5433/postgres"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_postgres_wrapper" {
  metadata {
    name      = "app-postgres-wrapper"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "app-postgres-wrapper"
    }
    port {
      port        = 50053
      target_port = 50053
    }
    type = "ClusterIP"
  }
}

# User Node Service
resource "kubernetes_deployment" "user_node_service" {
  metadata {
    name      = "user-node-service"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "user-node-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "user-node-service"
        }
      }
      spec {
        container {
          name              = "user-node-service"
          image            = "thesis-health-data-provider:latest"
          image_pull_policy = "Never"
          port {
            container_port = 3002
          }
          liveness_probe {
            http_get {
              path = "/check"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds       = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "user_node_service" {
  metadata {
    name      = "user-node-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "user-node-service"
    }
    port {
      port        = 3002
      target_port = 3002
    }
    type = "ClusterIP"
  }
}

# App Timescale Wrapper
resource "kubernetes_deployment" "app_timescale_wrapper" {
  metadata {
    name      = "app-timescale-wrapper"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "app-timescale-wrapper"
      }
    }
    template {
      metadata {
        labels = {
          app = "app-timescale-wrapper"
        }
      }
      spec {
        container {
          name              = "app-timescale-wrapper"
          image            = "thesis-timescale-service:latest"
          image_pull_policy = "Never"
          port {
            container_port = 3000
          }
          port {
            container_port = 50051
          }
          env {
            name  = "TIMESCALE_URL"
            value = "postgres://postgres:pass@timescaledb:5432/timescaledb"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_timescale_wrapper" {
  metadata {
    name      = "app-timescale-wrapper"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = "app-timescale-wrapper"
    }
    port {
      name        = "http"
      port        = 3000
      target_port = 3000
    }
    port {
      name        = "grpc"
      port        = 50051
      target_port = 50051
    }
    type = "ClusterIP"
  }
}

# Sensor Python Service
resource "kubernetes_deployment" "sensor_py_service" {
  metadata {
    name      = "sensor-py-service"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "sensor-py-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "sensor-py-service"
        }
      }
      spec {
        container {
          name              = "sensor-py-service"
          image            = "thesis-sensors-py-service:latest"
          image_pull_policy = "Never"
          port {
            container_port = 8000
          }
          env {
            name  = "PYTHONUNBUFFERED"
            value = "1"
          }
        }
      }
    }
  }
}

# resource "kubernetes_service" "sensor_py_service" {
#   metadata {
#     name      = "sensor-py-service"
#     namespace = var.namespace
#   }
#   spec {
#     selector = {
#       app = "sensor-py-service"
#     }