/**
 * # Outputs for VPC Peering Example
 */

output "hub_network_name" {
  description = "The name of the hub VPC network."
  value       = module.hub_spoke_network.hub_network_name
}

output "hub_subnets" {
  description = "A map of subnet names to subnet self-links in the hub VPC."
  value       = module.hub_spoke_network.hub_subnets_self_links
}

output "spoke_networks" {
  description = "A map of spoke names to VPC network names."
  value       = module.hub_spoke_network.spoke_networks_names
}

output "spoke_subnets" {
  description = "A map of spoke names to subnet self-links."
  value       = module.hub_spoke_network.spoke_subnets_self_links
}

output "vpc_peering_connections" {
  description = "A map of VPC peering connection resources."
  value       = module.hub_spoke_network.vpc_peering_connections
}

output "dns_zone" {
  description = "The private DNS zone resource (if created)."
  value       = module.hub_spoke_network.dns_zone
}