terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    # Укажите данные вашего S3 bucket для хранения состояния Terraform
    endpoint = "storage.yandexcloud.net"
    bucket   = "yc-backend"
    region   = "ru-central1"
    key      = "terraform.tfstate"
    # access_key provided via AWS_ACCESS_KEY_ID
    # secret_key provided via AWS_SECRET_ACCESS_KEY

    skip_region_validation      = true
    skip_credentials_validation = true
    workspace_key_prefix        = "diplom"
  }
}