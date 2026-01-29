
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

variable "vpc_name" {
  type        = string
  default     = "aleksandrov-vpc"
  description = "VPC network&subnet name"
}

variable "image_id" {
  type        = string 
  default     = "fd8lcd9f54ldmonh1d72" #ubuntu-2004-lts-oslogin
  description = "ubuntu-2404-lts-oslogin"
}

variable "each_subnet" {
  type = list(object({  subnet_name=string, subnet_zone=string, v4_cidr = list(string) }))
  default = [
    {
      subnet_name = "public",
      subnet_zone = "ru-central1-a",
      v4_cidr = ["192.168.10.0/24"]
    },
    {
      subnet_name = "public",
      subnet_zone = "ru-central1-b",
      v4_cidr = ["192.168.11.0/24"]
    },
    {
      subnet_name = "public",
      subnet_zone = "ru-central1-d",
      v4_cidr = ["192.168.12.0/24"]
    }
  ]
}

variable "vm_platform_id" {
  type        = string
  default     = "standard-v2"       
  description = "yandex platform"
}

variable "vms_ssh_root_key" {                                                             
  type = string
  description = "ssh-keygen -t ed25519"
  sensitive   = false
  }

variable "root_user_pass" {                                                             
  type = string
  description = "root user password"
  sensitive   = true
  }

variable "iam_token" {                                                             
  type = string
  description = "iam token"
  sensitive   = true
  }

variable "each_vm" {
  type = list(object({  vm_name=string, cpu=number, ram=number, disk_volume=number, core_fraction = number, role = string, subnet = string }))
  default = [
    {
      vm_name = "k8s-master-01",
      cpu = 2,
      ram = 4,
      disk_volume = 20,
      core_fraction = 50
      role          = "master"
      subnet = "public-ru-central1-a"
    },
    {
      vm_name = "k8s-worker-01",
      cpu = 2,
      ram = 4,
      disk_volume = 20,
      core_fraction = 50
      role          = "worker"
      subnet = "public-ru-central1-a"
    },
    {
      vm_name = "k8s-worker-02",
      cpu = 2,
      ram = 4,
      disk_volume = 20,
      core_fraction = 50
      role          = "worker"
      subnet = "public-ru-central1-b"
    }
    # {
    #   vm_name = "k8s-worker-03",
    #   cpu = 2,
    #   ram = 4,
    #   disk_volume = 20,
    #   core_fraction = 50
    #   role          = "worker"
    #   subnet = "public-ru-central1-d"
    # }
    # {
    #   vm_name = "k8s-worker-04",
    #   cpu = 2,
    #   ram = 2,
    #   disk_volume = 15,
    #   core_fraction = 100
    #   role          = "worker"
    #   subnet = "public-ru-central1-a"
    #}
  ]
}
