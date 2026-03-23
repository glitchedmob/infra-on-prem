variable "network_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID (2-4094) - must not be 1 (native VLAN handled separately)"
  type        = number
}

variable "router_parent_interface" {
  description = "Parent interface on router for the VLAN - must be a reference to a resource, not a hardcoded string"
  type        = string
}

variable "network_cidr" {
  description = "CIDR block for the network (e.g., 10.0.20.0/24)"
  type        = string
}

variable "gateway_ip" {
  description = "Gateway IP address within the CIDR. Defaults to first usable IP in the network (.1)"
  type        = string
  default     = ""
}

variable "dhcp_pool_start" {
  description = "Start IP for DHCP pool"
  type        = string
}

variable "dhcp_pool_end" {
  description = "End IP for DHCP pool"
  type        = string
}

variable "dns_records" {
  description = "Static DNS records to create for this network"
  type = map(object({
    ip      = string
    comment = optional(string, "")
  }))
  default = {}
}

variable "switch_bridge_name" {
  description = "Name of the bridge on the switch - must be a reference to a resource"
  type        = string
}

variable "switch_tagged_ports" {
  description = "List of tagged port interface names on the switch for this VLAN"
  type        = list(string)
  default     = []
}

variable "switch_access_ports" {
  description = "List of access (untagged) port interface names on the switch for this VLAN"
  type        = list(string)
  default     = []
}

variable "switch_parent_interface" {
  description = "Parent interface on switch for the VLAN - must be a reference to a resource"
  type        = string
}

variable "router_bridge_name" {
  description = "Name of the bridge on the router - must be a reference to a resource"
  type        = string
}

variable "router_tagged_ports" {
  description = "List of tagged port interface names on the router for this VLAN"
  type        = list(string)
  default     = []
}

variable "router_access_ports" {
  description = "List of access (untagged) port interface names on the router for this VLAN"
  type        = list(string)
  default     = []
}
