locals {
  admin_devices = {
    levi_framework = {
      address     = "192.168.1.10"
      mac_address = "52:0d:40:03:78:a5"
      comment     = "managedBy=terraform,network=home,role=admin"
    }
    levi_macbook = {
      address     = "192.168.1.11"
      mac_address = "42:6d:65:36:5d:e3"
      comment     = "managedBy=terraform,network=home,role=admin"
    }
  }
}

resource "routeros_ip_dhcp_server_lease" "admin_devices" {
  for_each = local.admin_devices

  provider     = routeros.router
  address      = each.value.address
  mac_address  = each.value.mac_address
  block_access = false
  comment      = "${each.value.comment},device=${each.key}"
}
