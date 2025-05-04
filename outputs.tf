/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Hub network outputs
output "hub_network" {
  description = "The hub VPC network resource."
  value       = module.hub.network
}

output "hub_network_id" {
  description = "The ID of the hub VPC network."
  value       = module.hub.network_id
}

output "hub_network_name" {
  description = "The name of the hub VPC network."
  value       = module.hub.network_name
}

output "hub_network_self_link" {
  description = "The self-link of the hub VPC network."
  value       = module.hub.network_self_link
}

output "hub_subnets" {
  description = "A map of subnet names to subnet resources in the hub VPC."
  value       = module.hub.subnets
}

output "hub_subnets_ids" {
  description = "A map of subnet names to subnet IDs in the hub VPC."
  value       = module.hub.subnets_ids
}

output "hub_subnets_self_links" {
  description = "A map of subnet names to subnet self-links in the hub VPC."
  value       = module.hub.subnets_self_links
}

output "hub_subnets_regions" {
  description = "A map of subnet names to subnet regions in the hub VPC."
  value       = module.hub.subnets_regions
}

# Spoke networks outputs
output "spoke_networks" {
  description = "A map of spoke names to VPC network resources."
  value = {
    for name, spoke in module.spoke :
    name => spoke.network
  }
}

output "spoke_networks_ids" {
  description = "A map of spoke names to VPC network IDs."
  value = {
    for name, spoke in module.spoke :
    name => spoke.network_id
  }
}

output "spoke_networks_names" {
  description = "A map of spoke names to VPC network names."
  value = {
    for name, spoke in module.spoke :
    name => spoke.network_name
  }
}

output "spoke_networks_self_links" {
  description = "A map of spoke names to VPC network self-links."
  value = {
    for name, spoke in module.spoke :
    name => spoke.network_self_link
  }
}

output "spoke_subnets" {
  description = "A map of spoke names to subnet resources."
  value = {
    for name, spoke in module.spoke :
    name => spoke.subnets
  }
}

output "spoke_subnets_ids" {
  description = "A map of spoke names to subnet IDs."
  value = {
    for name, spoke in module.spoke :
    name => spoke.subnets_ids
  }
}

output "spoke_subnets_self_links" {
  description = "A map of spoke names to subnet self-links."
  value = {
    for name, spoke in module.spoke :
    name => spoke.subnets_self_links
  }
}

# Network Connectivity Center outputs
output "ncc_hub" {
  description = "The Network Connectivity Center hub resource (if created)."
  value       = local.using_ncc ? module.ncc[0].ncc_hub : null
}

output "ncc_hub_id" {
  description = "The ID of the Network Connectivity Center hub (if created)."
  value       = local.using_ncc ? module.ncc[0].ncc_hub_id : null
}

output "ncc_hub_self_link" {
  description = "The self-link of the Network Connectivity Center hub (if created)."
  value       = local.using_ncc ? module.ncc[0].ncc_hub_self_link : null
}

output "ncc_spokes" {
  description = "A map of spoke names to Network Connectivity Center spoke resources (if created)."
  value       = local.using_ncc ? module.ncc[0].ncc_spokes : null
}

# VPC Peering outputs
output "vpc_peering_connections" {
  description = "A map of VPC peering connection resources (if created)."
  value       = local.using_vpc_peering ? module.peering[0].peering_connections : null
}

# VPN outputs
output "vpn_tunnels" {
  description = "A map of VPN tunnel resources (if created)."
  value       = local.using_vpn ? module.vpn[0].vpn_tunnels : null
}

output "vpn_gateways" {
  description = "A map of VPN gateway resources (if created)."
  value       = local.using_vpn ? module.vpn[0].vpn_gateways : null
}

# DNS outputs
output "dns_zone" {
  description = "The private DNS zone resource (if created)."
  value       = var.enable_private_dns ? module.dns[0].dns_zone : null
}

output "dns_zone_id" {
  description = "The ID of the private DNS zone (if created)."
  value       = var.enable_private_dns ? module.dns[0].dns_zone_id : null
}

output "dns_zone_name" {
  description = "The name of the private DNS zone (if created)."
  value       = var.enable_private_dns ? module.dns[0].dns_zone_name : null
}

output "dns_forwarding_zones" {
  description = "A map of DNS forwarding zone resources (if created)."
  value       = var.enable_private_dns ? module.dns[0].dns_forwarding_zones : null
}

# On-premises connectivity outputs
output "onprem_connectivity" {
  description = "Details of the on-premises connectivity resources (if created)."
  value       = local.enable_onprem ? module.onprem_connectivity[0].connectivity_details : null
}

# Transitivity outputs
output "transitivity_details" {
  description = "Details of the transitivity implementation (if created)."
  value       = var.enable_transitivity ? module.transitivity[0].transitivity_details : null
}