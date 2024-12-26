# variables.tf
variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "thesis"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "mysecretpassword"
}

variable "mongo_username" {
  description = "MongoDB username"
  type        = string
  default     = "Username"
}

variable "mongo_password" {
  description = "MongoDB password"
  type        = string
  default     = "Password"
}

variable "minio_root_user" {
  description = "MinIO root user"
  type        = string
  default     = "username"
}

variable "minio_root_password" {
  description = "MinIO root password"
  type        = string
  default     = "password"
}

variable "timescale_password" {
  description = "TimescaleDB password"
  type        = string
  default     = "pass"
}