/**
 * # Outputs for Network Connectivity Center Example
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

output "ncc_hub" {
  description = "The Network Connectivity Center hub resource."
  value       = module.hub_spoke_network.ncc_hub
}

output "ncc_spokes" {
  description = "A map of spoke names to Network Connectivity Center spoke resources."
  value       = module.hub_spoke_network.ncc_spokes
}

output "dns_zone" {
  description = "The private DNS zone resource (if created)."
  value       = module.hub_spoke_network.dns_zone
}

output "test_vms" {
  description = "Details of test VMs (if created)."
  value = var.create_test_vms ? {
    hub_vm    = google_compute_instance.hub_vm[0].name
    spoke_vms = {
      for k, v in google_compute_instance.spoke_vms : k => v.name
    }
  } : null
}

output "transitivity_enabled" {
  description = "Whether transitivity between spokes is enabled."
  value       = var.enable_transitivity
}

output "onprem_connectivity" {
  description = "Details of the on-premises connectivity (if enabled)."
  value       = module.hub_spoke_network.onprem_connectivity
}