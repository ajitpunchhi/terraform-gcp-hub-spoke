/**
 * # GCP Hub and Spoke Network Module
 *
 * This module creates a Hub and Spoke network architecture in Google Cloud Platform.
 * It supports three connectivity models: VPC Peering, Network Connectivity Center, or Cloud VPN.
 */

locals {
  # Create a map of spoke networks for easier reference
  spoke_networks_map = {
    for spoke in var.spoke_networks :
    spoke.name => spoke
  }

  # Determine if we're using the same project for hub and spokes
  hub_project_id = var.hub_project_id != "" ? var.hub_project_id : var.project_id
  
  # Determine if Network Connectivity Center is being used
  using_ncc = var.connection_type == "ncc"
  
  # Determine if VPC Peering is being used
  using_vpc_peering = var.connection_type == "vpc_peering"
  
  # Determine if VPN is being used
  using_vpn = var.connection_type == "vpn"
  
  # Determine if on-premises connectivity is enabled
  enable_onprem = var.enable_onprem_connectivity
}

# Create the hub network
module "hub" {
  source = "./modules/hub"
  
  project_id        = local.hub_project_id
  network_name      = var.hub_network_name
  subnets           = var.hub_subnets
  region            = var.region
  enable_cloud_nat  = var.enable_cloud_nat
  
  # Pass required labels
  labels = var.labels
}

# Create spoke networks
module "spoke" {
  source   = "./modules/spoke"
  for_each = local.spoke_networks_map
  
  project_id      = each.value.project_id != null ? each.value.project_id : var.project_id
  network_name    = each.value.network_name
  subnets         = each.value.subnets
  region          = var.region
  enable_cloud_nat = each.value.enable_cloud_nat != null ? each.value.enable_cloud_nat : false
  
  # Pass required labels
  labels = var.labels
}

# Create Network Connectivity Center if specified
module "ncc" {
  source = "./modules/ncc"
  count  = local.using_ncc ? 1 : 0
  
  project_id    = local.hub_project_id
  ncc_hub_name  = var.ncc_hub_name
  ncc_topology  = var.ncc_topology
  hub_network   = module.hub.network
  spoke_networks = {
    for name, spoke in module.spoke :
    name => spoke.network
  }
  region = var.region
}

# Create VPC peering connections if specified
module "peering" {
  source = "./modules/peering"
  count  = local.using_vpc_peering ? 1 : 0
  
  hub_project_id     = local.hub_project_id
  hub_network        = module.hub.network
  hub_network_name   = module.hub.network_name
  spoke_networks     = {
    for name, spoke in module.spoke :
    name => {
      project_id   = spoke.project_id
      network_name = spoke.network_name
      network      = spoke.network
    }
  }
  export_routes = var.peering_export_custom_routes
  import_routes = var.peering_import_custom_routes
}

# Create VPN connections if specified
module "vpn" {
  source = "./modules/vpn"
  count  = local.using_vpn ? 1 : 0
  
  project_id      = local.hub_project_id
  hub_network     = module.hub.network
  hub_network_name = module.hub.network_name
  region          = var.region
  spoke_networks  = {
    for name, spoke in module.spoke :
    name => {
      project_id   = spoke.project_id
      network_name = spoke.network_name
      network      = spoke.network
      subnets      = spoke.subnets_self_links
    }
  }
}

# Create DNS configuration
module "dns" {
  source = "./modules/dns"
  count  = var.enable_private_dns ? 1 : 0
  
  project_id           = local.hub_project_id
  dns_zone_name        = var.dns_zone_name
  dns_domain           = var.dns_domain
  hub_network          = module.hub.network
  spoke_networks       = {
    for name, spoke in module.spoke :
    name => spoke.network
  }
  dns_forwarding_zones = var.dns_forwarding_zones
}

# Create transitivity if specified
module "transitivity" {
  source = "./modules/transitivity"
  count  = var.enable_transitivity ? 1 : 0
  
  project_id         = local.hub_project_id
  transitivity_method = var.transitivity_method
  hub_network        = module.hub.network
  hub_subnets        = module.hub.subnets
  region             = var.region
  spoke_networks     = {
    for name, spoke in module.spoke :
    name => {
      project_id   = spoke.project_id
      network_name = spoke.network_name
      network      = spoke.network
      subnets      = spoke.subnets_self_links
    }
  }
  
  # Pass NCC module output if using NCC for transitivity
  ncc_hub           = local.using_ncc ? module.ncc[0].ncc_hub : null
  
  # Only apply if using appropriate transitivity method
  # Only apply if using appropriate transitivity method
  # (count already defined earlier in the block)
}

# Create on-premises connectivity if specified
module "onprem_connectivity" {
  source = "./modules/onprem_connectivity"
  count  = local.enable_onprem ? 1 : 0
  
  project_id             = local.hub_project_id
  hub_network            = module.hub.network
  hub_network_name       = module.hub.network_name
  region                 = var.region
  onprem_cidr_ranges     = var.onprem_cidr_ranges
  onprem_connection_type = var.onprem_connection_type
  
  # Interconnect specific variables
  interconnect_attachments = var.onprem_connection_type == "interconnect" ? var.interconnect_attachments : []
  
  # VPN specific variables
  vpn_shared_secret       = var.onprem_connection_type == "vpn" ? var.vpn_shared_secret : ""
  vpn_gateway_ip          = var.onprem_connection_type == "vpn" ? var.vpn_gateway_ip : ""
}