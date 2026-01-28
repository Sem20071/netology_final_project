resource "yandex_compute_instance" "vms" {            
  for_each = { for k in var.each_vm : k.vm_name => k }
  name        = each.value.vm_name                                                             
  platform_id = var.vm_platform_id
  hostname    = each.value.vm_name
  zone        = yandex_vpc_subnet.subnets[each.value.subnet].zone
  resources {
    cores         = each.value.cpu                          
    memory        = each.value.ram                          
    core_fraction = each.value.core_fraction   

  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      type = "network-hdd"
      size = each.value.disk_volume
    }
  }

  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.subnets[each.value.subnet].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.public.id]
  }
  
  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }

}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    vms_ssh_root_key = var.vms_ssh_root_key
    root_user_pass = var.root_user_pass
  }
}
