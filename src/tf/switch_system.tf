resource "routeros_system_clock" "switch_clock" {
  provider       = routeros.switch
  time_zone_name = "UTC"
}

resource "routeros_ip_dns" "switch_dns" {
  provider = routeros.switch
  servers  = ["192.168.1.1"]
}
