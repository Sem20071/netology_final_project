# resource "yandex_vpc_security_group_rule" "ingress" {
#   security_group_binding = yandex_vpc_security_group.private.id
#   direction              = "ingress"
#   protocol               = "ANY"
#   description            = "all"
#   v4_cidr_blocks         = ["0.0.0.0/0"]
#   from_port              = 0
#   to_port                = 65535
# }

# resource "yandex_vpc_security_group_rule" "egress" {
#   security_group_binding = yandex_vpc_security_group.private.id
#   direction              = "egress"
#   protocol               = "ANY"
#   description            = "all"
#   v4_cidr_blocks         = ["0.0.0.0/0"]
#   from_port              = 0
#   to_port                = 65535
# }  