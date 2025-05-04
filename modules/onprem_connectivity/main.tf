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
  # Determine which connection type to use
  using_vpn = var.onprem_connection_type == "vpn"
  using_interconnect = var.onprem_connection_type == "interconnect"
  
  # Create a list of CIDR ranges for on-premises networks
  onprem_cidr_ranges = var.onprem_cidr_ranges
  
  # Generate a random secret for VPN tunnel if not provided
  vpn_shared_secret = var.vpn_shared_secret != "" ? var.vpn_shared_secret : random_string.vpn_shared_secret[0].result
}

# Generate a random shared secret for VPN tunnel if not provided
resource "random_string" "vpn_shared_secret" {
  count            = local.using_vpn && var.vpn_shared_secret == "" ? 1 : 0
  
  length           = 32
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

# Create Cloud Router for on-premises connectivity
resource "google_compute_router" "onprem_router" {
  name        = "${var.hub_network_name}-onprem-router"
  project     = var.project_id
  region      = var.region
  network     = var.hub_network.self_link
  description = "Router for on-premises connectivity"
  
  bgp {
    asn = var.gcp_router_asn
  }
}

# Create VPN Gateway for on-premises connectivity if using VPN
resource "google_compute_vpn_gateway" "onprem_vpn_gateway" {
  count = local.using_vpn ? 1 : 0
  
  name        = "${var.hub_network_name}-onprem-vpn-gateway"
  project     = var.project_id
  region      = var.region
  network     = var.hub_network.self_link
  description = "VPN Gateway for on-premises connectivity"
}

# Create static external IP for VPN tunnel if using VPN
resource "google_compute_address" "onprem_vpn_ip" {
  count = local.using_vpn ? 1 : 0
  
  name         = "${var.hub_network_name}-onprem-vpn-ip"
  project      = var.project_id
  region       = var.region
  address_type = "EXTERNAL"
  description  = "External IP for VPN tunnel to on-premises"
}

# Create VPN Tunnel to on-premises if using VPN
resource "google_compute_vpn_tunnel" "onprem_vpn_tunnel" {
  count = local.using_vpn ? 1 : 0
  
  name                    = "${var.hub_network_name}-to-onprem-tunnel"
  project                 = var.project_id
  region                  = var.region
  vpn_gateway             = google_compute_vpn_gateway.onprem_vpn_gateway[0].self_link
  peer_external_gateway   = var.vpn_gateway_ip != "" ? google_compute_external_vpn_gateway.onprem_external_gateway[0].self_link : null
  shared_secret           = local.vpn_shared_secret
  router                  = google_compute_router.onprem_router.name
  target_vpn_gateway      = google_compute_vpn_gateway.onprem_vpn_gateway[0].self_link
  remote_traffic_selector = ["0.0.0.0/0"]
  local_traffic_selector  = ["0.0.0.0/0"]
  ike_version             = var.ike_version
  
  depends_on = [
    google_compute_address.onprem_vpn_ip,
    google_compute_vpn_gateway.onprem_vpn_gateway,
    google_compute_router.onprem_router
  ]
}

# Create external VPN gateway for on-premises if using VPN and gateway IP is provided
resource "google_compute_external_vpn_gateway" "onprem_external_gateway" {
  count = local.using_vpn && var.vpn_gateway_ip != "" ? 1 : 0
  
  name            = "${var.hub_network_name}-onprem-external-gateway"
  project         = var.project_id
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  description     = "External VPN Gateway for on-premises connectivity"
  
  interface {
    id         = 0
    ip_address = var.vpn_gateway_ip
  }
}

# Create BGP peer for on-premises connectivity if using VPN
resource "google_compute_router_interface" "onprem_router_interface" {
  count = local.using_vpn ? 1 : 0
  
  name       = "${var.hub_network_name}-onprem-interface"
  project    = var.project_id
  region     = var.region
  router     = google_compute_router.onprem_router.name
  ip_range   = "${var.bgp_interface_ip_base}.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.onprem_vpn_tunnel[0].name
}

resource "google_compute_router_peer" "onprem_router_peer" {
  count = local.using_vpn ? 1 : 0
  
  name                      = "${var.hub_network_name}-onprem-peer"
  project                   = var.project_id
  region                    = var.region
  router                    = google_compute_router.onprem_router.name
  interface                 = google_compute_router_interface.onprem_router_interface[0].name
  peer_asn                  = var.onprem_router_asn
  peer_ip_address           = "${var.bgp_interface_ip_base}.2"
  advertised_route_priority = var.gcp_router_advertised_route_priority
}

# Create Cloud Interconnect resources if using Interconnect
resource "google_compute_interconnect_attachment" "interconnect_attachments" {
  for_each = local.using_interconnect ? { for i, a in var.interconnect_attachments : a.name => a } : {}
  
  name                     = each.value.name
  project                  = var.project_id
  region                   = each.value.region
  router                   = google_compute_router.onprem_router.self_link
  type                     = "DEDICATED"
  edge_availability_domain = each.value.edge_availability_domain
  admin_enabled            = lookup(each.value, "admin_enabled", true)
  description              = "Dedicated Interconnect attachment for on-premises connectivity"
  
  depends_on = [google_compute_router.onprem_router]
}

# Create BGP peer for each interconnect attachment if using Interconnect
resource "google_compute_router_interface" "interconnect_router_interfaces" {
  for_each = local.using_interconnect ? google_compute_interconnect_attachment.interconnect_attachments : {}
  
  name                    = "interconnect-${each.key}-interface"
  project                 = var.project_id
  region                  = each.value.region
  router                  = google_compute_router.onprem_router.name
  ip_range                = "${var.bgp_interface_ip_base}.${index(keys(var.interconnect_attachments), each.key) * 4 + 1}/30"
  interconnect_attachment = each.value.self_link
}

resource "google_compute_router_peer" "interconnect_router_peers" {
  for_each = local.using_interconnect ? google_compute_router_interface.interconnect_router_interfaces : {}
  
  name                      = "interconnect-${each.key}-peer"
  project                   = var.project_id
  region                    = var.region
  router                    = google_compute_router.onprem_router.name
  interface                 = each.value.name
  peer_asn                  = var.onprem_router_asn
  peer_ip_address           = "${var.bgp_interface_ip_base}.${index(keys(var.interconnect_attachments), each.key) * 4 + 2}"
  advertised_route_priority = var.gcp_router_advertised_route_priority
}