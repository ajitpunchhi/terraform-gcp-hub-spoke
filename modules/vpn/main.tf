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

locals {
  # Create a map for easier reference
  spoke_networks_map = var.spoke_networks
  
  # Generate a random secret for each VPN tunnel if not provided
  vpn_shared_secrets = {
    for name, spoke in local.spoke_networks_map :
    name => var.vpn_shared_secret != "" ? var.vpn_shared_secret : random_string.vpn_shared_secrets[name].result
  }
}

# Generate random shared secrets for VPN tunnels if not provided
resource "random_string" "vpn_shared_secrets" {
  for_each = local.spoke_networks_map
  
  length           = 32
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

# Create Cloud Router in hub network
resource "google_compute_router" "hub_router" {
  name        = "${var.hub_network_name}-vpn-router"
  project     = var.project_id
  region      = var.region
  network     = var.hub_network.self_link
  description = "Router for VPN tunnels in hub network"
  
  bgp {
    asn = var.hub_router_asn
  }
}

# Create VPN Gateway in hub network
resource "google_compute_vpn_gateway" "hub_gateway" {
  name        = "${var.hub_network_name}-vpn-gateway"
  project     = var.project_id
  region      = var.region
  network     = var.hub_network.self_link
  description = "VPN Gateway in hub network"
}

# Create Cloud Routers in spoke networks
resource "google_compute_router" "spoke_routers" {
  for_each = local.spoke_networks_map
  
  name        = "${each.value.network_name}-vpn-router"
  project     = each.value.project_id
  region      = var.region
  network     = each.value.network.self_link
  description = "Router for VPN tunnels in spoke network"
  
  bgp {
    asn = var.spoke_router_asn_base + index(keys(local.spoke_networks_map), each.key)
  }
}

# Create VPN Gateways in spoke networks
resource "google_compute_vpn_gateway" "spoke_gateways" {
  for_each = local.spoke_networks_map
  
  name        = "${each.value.network_name}-vpn-gateway"
  project     = each.value.project_id
  region      = var.region
  network     = each.value.network.self_link
  description = "VPN Gateway in spoke network"
}

# Create static external IPs for VPN tunnels in hub network
resource "google_compute_address" "hub_vpn_ips" {
  for_each = local.spoke_networks_map
  
  name         = "${var.hub_network_name}-vpn-ip-${each.key}"
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  description  = "External IP for VPN tunnel to ${each.key} spoke network"
}

# Create static external IPs for VPN tunnels in spoke networks
resource "google_compute_address" "spoke_vpn_ips" {
  for_each = local.spoke_networks_map
  
  name         = "${each.value.network_name}-vpn-ip"
  project      = each.value.project_id
  region       = var.region
  address_type = "EXTERNAL"
  description  = "External IP for VPN tunnel to hub network"
}

# Create VPN Tunnels from hub to spokes
resource "google_compute_vpn_tunnel" "hub_to_spoke_tunnels" {
  for_each = local.spoke_networks_map
  
  name                    = "${var.hub_network_name}-to-${each.key}-tunnel"
  project                 = var.project_id
  region                  = var.region
  vpn_gateway             = google_compute_vpn_gateway.hub_gateway.self_link
  peer_external_gateway   = null
  shared_secret           = local.vpn_shared_secrets[each.key]
  router                  = google_compute_router.hub_router.name
  target_vpn_gateway      = google_compute_vpn_gateway.hub_gateway.self_link
  remote_traffic_selector = ["0.0.0.0/0"]
  local_traffic_selector  = ["0.0.0.0/0"]
  ike_version             = var.ike_version
  
  depends_on = [
    google_compute_address.hub_vpn_ips,
    google_compute_vpn_gateway.hub_gateway,
    google_compute_router.hub_router
  ]
}

# Create VPN Tunnels from spokes to hub
resource "google_compute_vpn_tunnel" "spoke_to_hub_tunnels" {
  for_each = local.spoke_networks_map
  
  name                    = "${each.value.network_name}-to-hub-tunnel"
  project                 = each.value.project_id
  region                  = var.region
  vpn_gateway             = google_compute_vpn_gateway.spoke_gateways[each.key].self_link
  peer_external_gateway   = null
  shared_secret           = local.vpn_shared_secrets[each.key]
  router                  = google_compute_router.spoke_routers[each.key].name
  target_vpn_gateway      = google_compute_vpn_gateway.spoke_gateways[each.key].self_link
  remote_traffic_selector = ["0.0.0.0/0"]
  local_traffic_selector  = ["0.0.0.0/0"]
  ike_version             = var.ike_version
  
  depends_on = [
    google_compute_address.spoke_vpn_ips,
    google_compute_vpn_gateway.spoke_gateways,
    google_compute_router.spoke_routers
  ]
}

# Create BGP peer in hub router for each spoke
resource "google_compute_router_interface" "hub_router_interfaces" {
  for_each = local.spoke_networks_map
  
  name       = "${var.hub_network_name}-${each.key}-interface"
  project    = var.project_id
  region     = var.region
  router     = google_compute_router.hub_router.name
  ip_range   = "${var.hub_bgp_interface_ip_base}.${index(keys(local.spoke_networks_map), each.key) * 4}/30"
  vpn_tunnel = google_compute_vpn_tunnel.hub_to_spoke_tunnels[each.key].name
}

resource "google_compute_router_peer" "hub_router_peers" {
  for_each = local.spoke_networks_map
  
  name                      = "${var.hub_network_name}-${each.key}-peer"
  project                   = var.project_id
  region                    = var.region
  router                    = google_compute_router.hub_router.name
  interface                 = google_compute_router_interface.hub_router_interfaces[each.key].name
  peer_asn                  = var.spoke_router_asn_base + index(keys(local.spoke_networks_map), each.key)
  peer_ip_address           = "${var.hub_bgp_interface_ip_base}.${index(keys(local.spoke_networks_map), each.key) * 4 + 2}"
  advertised_route_priority = var.hub_router_advertised_route_priority
}

# Create BGP peer in spoke routers
resource "google_compute_router_interface" "spoke_router_interfaces" {
  for_each = local.spoke_networks_map
  
  name       = "${each.value.network_name}-hub-interface"
  project    = each.value.project_id
  region     = var.region
  router     = google_compute_router.spoke_routers[each.key].name
  ip_range   = "${var.hub_bgp_interface_ip_base}.${index(keys(local.spoke_networks_map), each.key) * 4 + 2}/30"
  vpn_tunnel = google_compute_vpn_tunnel.spoke_to_hub_tunnels[each.key].name
}

resource "google_compute_router_peer" "spoke_router_peers" {
  for_each = local.spoke_networks_map
  
  name                      = "${each.value.network_name}-hub-peer"
  project                   = each.value.project_id
  region                    = var.region
  router                    = google_compute_router.spoke_routers[each.key].name
  interface                 = google_compute_router_interface.spoke_router_interfaces[each.key].name
  peer_asn                  = var.hub_router_asn
  peer_ip_address           = "${var.hub_bgp_interface_ip_base}.${index(keys(local.spoke_networks_map), each.key) * 4 + 1}"
  advertised_route_priority = var.spoke_router_advertised_route_priority
}