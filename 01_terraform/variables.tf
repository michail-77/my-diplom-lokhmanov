variable "service_account_key_file" {
  type        = string
  description = "Yandex.Cloud service account key file"
}

variable "yc_auth_key_file" {
  type        = string
  description = "Yandex.Cloud auth key file"
}

variable "service_account_id" {
  type        = string
  description = "Yandex.Cloud service_account_id"
}

variable "cloud_id" {
  type        = string
  description = "Yandex.Cloud Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Yandex.Cloud Folder ID"
}

variable "default_zone_a" {
  type    = string
  default = "ru-central1-a"
}

variable "default_zone_b" {
  type    = string
  default = "ru-central1-b"
}

variable "default_zone_d" {
  type    = string
  default = "ru-central1-d"
}

variable "vpc_name" {
  type        = string
  default     = "netology"
  description = "Name for VPC network & subnets"
}

variable "public_image" {
  type        = string
  default     = "fd8re3hiqnikqr7j7m8s"
  description = "Yandex.Compute image ID"
}

variable "public_resources" {
  type = map(number)
  default = {
    cores         = 4
    memory        = 4
    core_fraction = 20
    size          = 50
  }
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub" # Укажите здесь путь к вашему открытому ключу SSH
}

variable "public_resources_node" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
    size          = 20
  }
}

# Определение списка нод
locals {
  nodes = {
    "node1" = {
      zone      = var.default_zone_b
      subnet_id = "central1-b"
      ip_offset = 2
      ssh_key   = var.ssh_public_key_path
    },
    "node2" = {
      zone      = var.default_zone_d
      subnet_id = "central1-d"
      ip_offset = 3
      ssh_key   = var.ssh_public_key_path
    }
  }
}

