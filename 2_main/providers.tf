terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.145.0"
    }
  }
  required_version = "~>1.8.4"
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
      # dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1g7g5qur1nsh9pakjnj/etnfohjsoman0q61epn9"
    }
    bucket = "private-tfstate"
    region = "ru-central1"
    key = "terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true   
    skip_s3_checksum            = true
    use_path_style              = true
    # dynamodb_table = "tfstate-lock"
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
  token     = var.iam_token 
  #service_account_key_file = file("../1_service-account-yc/authorized_key.json")
}