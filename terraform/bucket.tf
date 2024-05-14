# Создаем сервисный аккаунт для bucket
resource "yandex_iam_service_account" "bucket-sa" {
  name        = "bucket-sa"
  description = "service account for bucket"
}

# # Создаем роль для сервисного аккаунта
# resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
#   folder_id = "b1gb5mplcv6bu0g0eolj"
#   role      = "storage.editor"
#   member    = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
# }

# # Encription/decryption (Шифрование/дешифрование)
# resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
#   folder_id = var.folder_id
#   role      = "kms.keys.encrypterDecrypter"
#   member    = "serviceAccount:${yandex_iam_service_account.bucket-sa.id}"
# }

# # Создание статического ключа доступа (для доступа к бэкэнду хранилища)
# resource "yandex_iam_service_account_static_access_key" "bucket-static_access_key" {
#   service_account_id = yandex_iam_service_account.bucket-sa.id
#   description        = "Static access key for Terraform Backend Bucket"
# }

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

# # Создаем бэкэнд хранилище (с шифрованием данных)
# resource "yandex_storage_bucket" "backend-encrypted" {
  
#   bucket     = "yc-backend"

#   access_key = yandex_iam_service_account_static_access_key.bucket-static_access_key.access_key
#   secret_key = yandex_iam_service_account_static_access_key.bucket-static_access_key.secret_key

#   anonymous_access_flags {
#     read = false
#     list = false
#   }

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         kms_master_key_id = yandex_kms_symmetric_key.key-a.id
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }
# }