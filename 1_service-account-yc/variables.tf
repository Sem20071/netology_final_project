
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "iam_service_account_name" {                                                             
  type = string
  description = "iam service user name"
  sensitive   = true
  }

variable "iam_token" {
  description = "IAM token for Yandex Cloud authentication (will be auto-generated)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vms_ssh_root_key" {                                                             
  type = string
  description = "ssh-keygen -t ed25519"
  sensitive   = true
  default     = ""
  }

variable "root_user_pass" {                                                             
  type = string
  description = "root user password"
  sensitive   = true
  default     = "" # default     = null
  }