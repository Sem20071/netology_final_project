# data "local_file" "tfstate" {
#   filename = "${path.module}/../1_service-account-yc/terraform.tfstate"
# }

# locals {
#   tfstate_data = jsondecode(data.local_file.tfstate.content)
  
#   # извлекаем доступные ресурсы
#   all_resources = local.tfstate_data.resources
  
#   # Находим нужный ресурс
#   sa_key_resource = [
#     for r in local.all_resources :
#     r if r.type == "yandex_iam_service_account_static_access_key"
#   ][0]
  
#   # Извлекаем атрибуты
#   access_key = local.sa_key_resource.instances[0].attributes.access_key
#   secret_key = local.sa_key_resource.instances[0].attributes.secret_key
# }

# resource "local_file" "credentials_json" {
#   filename = "../3_main/backend.hcl"
#   content = <<-EOT
#     access_key = "${local.access_key}"
#     secret_key = "${local.secret_key}"
#   EOT
#   file_permission = "0600"
#   }

resource "yandex_kms_symmetric_key" "kms_key" {
  name              = "terraform-state-key"
  description       = "KMS key for Terraform state encryption"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}

resource "yandex_storage_bucket" "private-tfstate" {
  bucket     = "private-tfstate"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  force_destroy = true
  anonymous_access_flags {
    read = false
    list = false
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.kms_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}



