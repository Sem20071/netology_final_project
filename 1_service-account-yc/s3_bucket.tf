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
  depends_on = [local_sensitive_file.service-account-key,
                yandex_resourcemanager_folder_iam_member.k8s-roles,
                yandex_iam_service_account_key.terraform-sa-key,
                yandex_iam_service_account_static_access_key.sa-static-key,
                local_file.aws_credentials]
}



