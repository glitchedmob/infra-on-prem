resource "routeros_ip_firewall_filter" "input_established" {
  provider         = routeros.router
  chain            = "input"
  action           = "accept"
  connection_state = "established,related,untracked"
  comment          = "defconf: accept established,related,untracked"
}

resource "routeros_ip_firewall_filter" "input_invalid" {
  provider         = routeros.router
  chain            = "input"
  action           = "drop"
  connection_state = "invalid"
  comment          = "defconf: drop invalid"
}

resource "routeros_ip_firewall_filter" "input_icmp" {
  provider = routeros.router
  chain    = "input"
  action   = "accept"
  protocol = "icmp"
  comment  = "defconf: accept ICMP"
}

resource "routeros_ip_firewall_filter" "input_loopback" {
  provider    = routeros.router
  chain       = "input"
  action      = "accept"
  dst_address = "127.0.0.1"
  comment     = "defconf: accept to local loopback (for CAPsMAN)"
}

resource "routeros_ip_firewall_filter" "input_lan_allow" {
  provider          = routeros.router
  chain             = "input"
  action            = "accept"
  in_interface_list = routeros_interface_list.router_lan.name
  place_before      = routeros_ip_firewall_filter.input_drop_non_lan.id
  comment           = "managedBy=terraform,scope=home-to-router,action=allow"
}

resource "routeros_ip_firewall_filter" "input_mgmt_allow" {
  provider          = routeros.router
  chain             = "input"
  action            = "accept"
  in_interface_list = routeros_interface_list.router_management.name
  place_before      = routeros_ip_firewall_filter.input_drop_non_lan.id
  comment           = "managedBy=terraform,scope=mgmt-to-router,action=allow"
}

resource "routeros_ip_firewall_filter" "input_project_dns_udp" {
  provider          = routeros.router
  chain             = "input"
  action            = "accept"
  protocol          = "udp"
  dst_port          = "53"
  in_interface_list = routeros_interface_list.router_project_vlans.name
  place_before      = routeros_ip_firewall_filter.input_drop_non_lan.id
  comment           = "managedBy=terraform,scope=projects-to-router,service=dns-udp,action=allow"
}

resource "routeros_ip_firewall_filter" "input_project_dns_tcp" {
  provider          = routeros.router
  chain             = "input"
  action            = "accept"
  protocol          = "tcp"
  dst_port          = "53"
  in_interface_list = routeros_interface_list.router_project_vlans.name
  place_before      = routeros_ip_firewall_filter.input_drop_non_lan.id
  comment           = "managedBy=terraform,scope=projects-to-router,service=dns-tcp,action=allow"
}

resource "routeros_ip_firewall_filter" "input_project_dhcp" {
  provider          = routeros.router
  chain             = "input"
  action            = "accept"
  protocol          = "udp"
  dst_port          = "67"
  in_interface_list = routeros_interface_list.router_project_vlans.name
  place_before      = routeros_ip_firewall_filter.input_drop_non_lan.id
  comment           = "managedBy=terraform,scope=projects-to-router,service=dhcp,action=allow"
}

resource "routeros_ip_firewall_filter" "input_project_drop" {
  provider          = routeros.router
  chain             = "input"
  action            = "drop"
  in_interface_list = routeros_interface_list.router_project_vlans.name
  place_before      = routeros_ip_firewall_filter.input_drop_non_lan.id
  comment           = "managedBy=terraform,scope=projects-to-router,action=drop"
}

resource "routeros_ip_firewall_filter" "input_drop_non_lan" {
  provider          = routeros.router
  chain             = "input"
  action            = "drop"
  in_interface_list = "!LAN"
  comment           = "defconf: drop all not coming from LAN"
}

resource "routeros_ip_firewall_filter" "forward_ipsec_in" {
  provider     = routeros.router
  chain        = "forward"
  action       = "accept"
  ipsec_policy = "in,ipsec"
  comment      = "defconf: accept in ipsec policy"
}

resource "routeros_ip_firewall_filter" "forward_ipsec_out" {
  provider     = routeros.router
  chain        = "forward"
  action       = "accept"
  ipsec_policy = "out,ipsec"
  comment      = "defconf: accept out ipsec policy"
}

resource "routeros_ip_firewall_filter" "forward_fasttrack" {
  provider         = routeros.router
  chain            = "forward"
  action           = "fasttrack-connection"
  connection_state = "established,related"
  comment          = "defconf: fasttrack"
}

resource "routeros_ip_firewall_filter" "forward_established" {
  provider         = routeros.router
  chain            = "forward"
  action           = "accept"
  connection_state = "established,related,untracked"
  comment          = "defconf: accept established,related, untracked"
}

resource "routeros_ip_firewall_filter" "forward_invalid" {
  provider         = routeros.router
  chain            = "forward"
  action           = "drop"
  connection_state = "invalid"
  comment          = "defconf: drop invalid"
}

resource "routeros_ip_firewall_filter" "forward_admin_allow" {
  for_each = local.admin_devices

  provider    = routeros.router
  chain       = "forward"
  action      = "accept"
  src_address = each.value.address
  comment     = "managedBy=terraform,role=admin,device=${each.key}"
}

resource "routeros_ip_firewall_filter" "forward_mgmt_to_project_allow" {
  provider           = routeros.router
  chain              = "forward"
  action             = "accept"
  in_interface_list  = routeros_interface_list.router_management.name
  out_interface_list = routeros_interface_list.router_project_vlans.name
  comment            = "managedBy=terraform,scope=mgmt-to-projects,action=allow"
}

resource "routeros_ip_firewall_filter" "forward_project_to_mgmt_drop" {
  provider           = routeros.router
  chain              = "forward"
  action             = "drop"
  in_interface_list  = routeros_interface_list.router_project_vlans.name
  out_interface_list = routeros_interface_list.router_management.name
  comment            = "managedBy=terraform,scope=projects-to-mgmt,action=drop"
}

resource "routeros_ip_firewall_filter" "forward_project_isolation_drop" {
  provider           = routeros.router
  chain              = "forward"
  action             = "drop"
  in_interface_list  = routeros_interface_list.router_project_vlans.name
  out_interface_list = routeros_interface_list.router_project_vlans.name
  comment            = "managedBy=terraform,scope=project-inter-vlan,action=drop"
}

resource "routeros_ip_firewall_filter" "forward_wan_drop" {
  provider             = routeros.router
  chain                = "forward"
  action               = "drop"
  connection_nat_state = "!dstnat"
  connection_state     = "new"
  in_interface_list    = routeros_interface_list.router_wan.name
  comment              = "defconf: drop all from WAN not DSTNATed"
}

resource "routeros_ip_firewall_nat" "masquerade" {
  provider           = routeros.router
  chain              = "srcnat"
  action             = "masquerade"
  ipsec_policy       = "out,none"
  out_interface_list = routeros_interface_list.router_wan.name
  comment            = "defconf: masquerade"
}
