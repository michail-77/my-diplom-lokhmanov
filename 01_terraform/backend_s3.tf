terraform {
  required_version = ">= 1.5.0"
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
