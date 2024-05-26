# Создаем сервисный аккаунт для bucket
resource "yandex_iam_service_account" "bucket-sa" {
  name        = "bucket-sa"
  description = "service account for bucket"
}

# Создаем ключи для сервисного аккаунта (для доступа к объектному хранилищу)
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.bucket-sa.id
  description        = "static access key for object storage"
}

# Ключ KMS для хранилища (для шифрования данных в хранилище)
resource "yandex_kms_symmetric_key" "key-a" {
  folder_id         = var.folder_id
  name              = "symmetric-key"
  description       = "Simmetric key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
  lifecycle {
    prevent_destroy = false
  }
}
