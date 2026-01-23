resource "yandex_vpc_network" "aleksandrov-vpc" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnets" {
  for_each = { 
    for idx, subnet in var.each_subnet : 
    "${subnet.subnet_name}-${subnet.subnet_zone}" => subnet 
  }
  name           = "${each.value.subnet_name}-${each.value.subnet_zone}"
  zone           = each.value.subnet_zone                                          
  network_id     = yandex_vpc_network.aleksandrov-vpc.id
  v4_cidr_blocks = each.value.v4_cidr
}


