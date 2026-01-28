resource "yandex_alb_http_router" "router" {
  name = "k8s-router"
}

resource "yandex_alb_target_group" "k8s-balancer-group" {
  name       = "k8s-balancer-group"
  depends_on = [yandex_compute_instance.vms]

  dynamic "target" {
    for_each = { for k, v in yandex_compute_instance.vms : k => v if k != "0" }
    content {
      subnet_id = target.value.network_interface.0.subnet_id
      ip_address   = target.value.network_interface.0.ip_address
    }
  }
}

resource "yandex_alb_backend_group" "grafana-bg" {
  name = "grafana-bg"
  depends_on = [yandex_alb_target_group.k8s-balancer-group]
  http_backend {
    name             = "grafana"
    weight           = 1
    port             = 30080
    target_group_ids = ["${yandex_alb_target_group.k8s-balancer-group.id}"]
    
    healthcheck {
      timeout             = "3s"
      interval           = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      http_healthcheck {
        path = "/api/health"
      }
    }
  }
}

resource "yandex_alb_backend_group" "miniapp-bg" {
  name = "miniapp-bg"
  depends_on = [yandex_alb_target_group.k8s-balancer-group]
  http_backend {
    name             = "miniapp"
    weight           = 1
    port             = 30055
    target_group_ids = ["${yandex_alb_target_group.k8s-balancer-group.id}"]
    
    healthcheck {
      timeout             = "3s"
      interval           = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "k8s-virtual-host"
  http_router_id = yandex_alb_http_router.router.id
  authority      = ["*"]
  
  depends_on = [
    yandex_alb_backend_group.grafana-bg,
    yandex_alb_backend_group.miniapp-bg
  ]

  route {
    name = "grafana-route"
    http_route {
      http_match {
        path {
          prefix = "/grafana"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.grafana-bg.id
      }
    }
  }

  route {
    name = "miniapp-route"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.miniapp-bg.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name               = "k8s-alb"
  network_id         = yandex_vpc_network.aleksandrov-vpc.id
  security_group_ids = [yandex_vpc_security_group.public.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnets["public-ru-central1-a"].id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }

  depends_on = [yandex_alb_virtual_host.virtual-host]
}