resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/hosts.tftpl", {
    vms = yandex_compute_instance.vms
    vm_config_map = { for vm in var.each_vm : vm.vm_name => vm }
  })
  filename = "${path.module}/ansible-config-k8s-cluster/hosts.ini"
}

resource "null_resource" "ansible_provisioner" {
  triggers = {
    playbook_hash      = filemd5("${path.module}/ansible-config-k8s-cluster/k8s-cluster-config.yaml")
    vm_count           = length(yandex_compute_instance.vms)
    vm_ids = join(",", [
      for vm in yandex_compute_instance.vms : vm.id
    ])
  }

  provisioner "local-exec" {
    command = "sleep 60 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${path.module}/ansible-config-k8s-cluster/hosts.ini ${path.module}/ansible-config-k8s-cluster/k8s-cluster-config.yaml -u ansible-user --extra-vars 'ansible_ssh_pass=$TF_VAR_root_user_pass ansible_become_pass=$TF_VAR_root_user_pass'"
    
    environment = {
      ANSIBLE_FORCE_COLOR = "true"
    }
  }

  depends_on = [
    local_file.ansible_inventory,
    yandex_compute_instance.vms
  ]
}
