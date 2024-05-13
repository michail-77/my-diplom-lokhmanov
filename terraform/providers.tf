# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
    required_version = ">=0.13"
}


provider "yandex" {
  # Укажите вашу авторизационную информацию
  service_account_key_file="authorized_key.json"
  # token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

data "yandex_compute_image" "public-ubuntu" {
  image_id = var.public_image
}