# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
    backend "s3" {
    # Укажите данные вашего S3 bucket для хранения состояния Terraform
    endpoint = "storage.yandexcloud.net"
    bucket   = "yc-backend"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}


provider "yandex" {
  # Укажите вашу авторизационную информацию
  service_account_key_file = file("authorized_key.json")
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}

data "yandex_compute_image" "public-ubuntu" {
  image_id = var.public_image
}
