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

output "connectivity_details" {
  description = "Details of the on-premises connectivity resources."
  value = {
    connection_type = var.onprem_connection_type
    
    # General resources
    onprem_router = google_compute_router.onprem_router
    
    # VPN resources
    vpn_gateway = local.using_vpn ? google_compute_vpn_gateway.onprem_vpn_gateway[0] : null
    vpn_ip = local.using_vpn ? google_compute_address.onprem_vpn_ip[0] : null
    vpn_tunnel = local.using_vpn ? google_compute_vpn_tunnel.onprem_vpn_tunnel[0] : null
    external_gateway = local.using_vpn && var.vpn_gateway_ip != "" ? google_compute_external_vpn_gateway.onprem_external_gateway[0] : null
    vpn_router_interface = local.using_vpn ? google_compute_router_interface.onprem_router_interface[0] : null
    vpn_router_peer = local.using_vpn ? google_compute_router_peer.onprem_router_peer[0] : null
    
    # Interconnect resources
    interconnect_attachments = local.using_interconnect ? google_compute_interconnect_attachment.interconnect_attachments : null
    interconnect_router_interfaces = local.using_interconnect ? google_compute_router_interface.interconnect_router_interfaces : null
    interconnect_router_peers = local.using_interconnect ? google_compute_router_peer.interconnect_router_peers : null
  }
}

output "onprem_router" {
  description = "The Cloud Router resource for on-premises connectivity."
  value       = google_compute_router.onprem_router
}

output "vpn_gateway" {
  description = "The VPN Gateway resource for on-premises connectivity (if using VPN)."
  value       = local.using_vpn ? google_compute_vpn_gateway.onprem_vpn_gateway[0] : null
}

output "vpn_tunnel" {
  description = "The VPN Tunnel resource for on-premises connectivity (if using VPN)."
  value       = local.using_vpn ? google_compute_vpn_tunnel.onprem_vpn_tunnel[0] : null
}

output "interconnect_attachments" {
  description = "A map of interconnect attachment resources (if using Interconnect)."
  value       = local.using_interconnect ? google_compute_interconnect_attachment.interconnect_attachments : null
}

output "advertised_routes" {
  description = "The list of CIDR ranges advertised to on-premises."
  value       = var.onprem_cidr_ranges
}