output "vm_instances" {
  description = "Все созданные ВМ с их параметрами"
  value = {
    for name, instance in yandex_compute_instance.vms : name => {
      "name"       = instance.name
      "public_ip"  = instance.network_interface[0].nat_ip_address
    }
  }
}

# output "file_content" {
#   description = "config k8s cluster"
#   value       = file("${path.module}/ansible-config-k8s-cluster/.artifact/config")
# }