resource "yandex_iam_service_account" "terraform-sa" {
  name        = var.iam_service_account_name
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-roles" {
  for_each = toset([
    "editor",
    "storage.admin",
#    "container-registry.images.puller",
    "kms.keys.encrypterDecrypter",
#    "load-balancer.admin",
    "vpc.publicAdmin",
    "certificate-manager.certificates.downloader",
    "kms.keys.encrypterDecrypter",
    "logging.writer",
#    "monitoring.viewer"
  ])
  
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.terraform-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.terraform-sa.id
  description        = "Static access key for Terraform"
}

resource "local_file" "aws_credentials" {
  filename = "${path.module}/.terraform.env"
  content  = <<-EOT
AWS_ACCESS_KEY_ID=${yandex_iam_service_account_static_access_key.sa-static-key.access_key}
AWS_SECRET_ACCESS_KEY=${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}
TF_VAR_cloud_id=${var.cloud_id}
TF_VAR_folder_id=${var.folder_id}
TF_VAR_root_user_pass=${var.root_user_pass}
TF_VAR_vms_ssh_root_key="${var.vms_ssh_root_key}"

  EOT
}

resource "yandex_iam_service_account_key" "terraform-sa-key" {
  service_account_id = yandex_iam_service_account.terraform-sa.id
  description        = "Статический ключ доступа"
  key_algorithm      = "RSA_4096"
  }

resource "local_sensitive_file" "service-account-key" {
  filename = "${path.module}/authorized_key.json"
  content = jsonencode({
    "id"                 = yandex_iam_service_account_key.terraform-sa-key.id
    "service_account_id" = yandex_iam_service_account.terraform-sa.id
    "created_at"         = yandex_iam_service_account_key.terraform-sa-key.created_at
    "key_algorithm"      = yandex_iam_service_account_key.terraform-sa-key.key_algorithm
    "public_key"         = yandex_iam_service_account_key.terraform-sa-key.public_key
    "private_key"        = yandex_iam_service_account_key.terraform-sa-key.private_key
  })
  file_permission = "0600"
}

# Локальный provisioner для получения IAM-токена
resource "null_resource" "simple_token" {
  depends_on = [local_sensitive_file.service-account-key,
                yandex_resourcemanager_folder_iam_member.k8s-roles,
                yandex_iam_service_account_key.terraform-sa-key,
                yandex_iam_service_account_static_access_key.sa-static-key,
                local_file.aws_credentials]

  provisioner "local-exec" {
    command = <<-EOT

      # Инициализируем yc с ключом сервисного аккаунта
      yc config profile create terraform-sa-profile 2>/dev/null || true
      yc config set service-account-key ./authorized_key.json --profile terraform-sa-profile
      
      # Получаем IAM-токен
      echo "Getting IAM token..."
      yc iam create-token --profile terraform-sa-profile > token.hcl
      
      if [ -f .terraform.env ]; then
        # Удаляем старую строку с TF_VAR_iam_token если есть
        grep -v "^TF_VAR_iam_token=" .terraform.env > .env.tmp && mv .env.tmp .env
      fi
      
      # Добавляем новые переменные
      echo "TF_VAR_iam_token=$(cat token.hcl)" >> .terraform.env
      
      rm -f token.hcl

    EOT

    interpreter = ["bash", "-c"]
    on_failure = fail
  }
}