resource "yandex_vpc_security_group" "public" {
  name        = "public"
  description = "security group public"
  network_id  = yandex_vpc_network.aleksandrov-vpc.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [ "0.0.0.0/0" ]
    description    = "HTTP connect"
  }

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [ "0.0.0.0/0" ]
    description    = "SSH connect"
  }

  ingress {
    protocol       = "TCP"
    port           = 30080
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Grafana health checks"
  }

  ingress {
    protocol       = "TCP"
    port           = 30055
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Miniapp health checks"
  }

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = [ "192.168.0.0/16" ]
    description    = "intranetwork traffic"
  }

  ingress {
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = [ "0.0.0.0/0" ]
    description    = "kube-apiserver"
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "outgoing traffic"
  }
}