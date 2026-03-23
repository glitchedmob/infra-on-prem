resource "routeros_system_clock" "router_clock" {
  provider       = routeros.router
  time_zone_name = "UTC"
}

resource "routeros_tool_mac_server" "router_mac_server" {
  provider               = routeros.router
  allowed_interface_list = routeros_interface_list.router_lan.name
}

resource "routeros_ip_dns" "router_dns" {
  provider              = routeros.router
  allow_remote_requests = true
  servers               = ["1.1.1.1", "1.0.0.1", "2606:4700:4700::1111", "2606:4700:4700::1001"]
  use_doh_server        = "https://cloudflare-dns.com/dns-query"
}

resource "routeros_dns_record" "router_lan" {
  provider = routeros.router
  name     = "router.lan"
  type     = "A"
  address  = "192.168.88.1"
  ttl      = "1d"
  comment  = "defconf"
}
