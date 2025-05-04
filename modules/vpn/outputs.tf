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

output "hub_router" {
  description = "The Cloud Router resource in the hub network."
  value       = google_compute_router.hub_router
}

output "hub_vpn_gateway" {
  description = "The VPN Gateway resource in the hub network."
  value       = google_compute_vpn_gateway.hub_gateway
}

output "spoke_routers" {
  description = "A map of spoke names to Cloud Router resources."
  value       = google_compute_router.spoke_routers
}

output "spoke_vpn_gateways" {
  description = "A map of spoke names to VPN Gateway resources."
  value       = google_compute_vpn_gateway.spoke_gateways
}

output "hub_vpn_ips" {
  description = "A map of spoke names to external IP addresses for VPN tunnels in the hub network."
  value       = google_compute_address.hub_vpn_ips
}

output "spoke_vpn_ips" {
  description = "A map of spoke names to external IP addresses for VPN tunnels in spoke networks."
  value       = google_compute_address.spoke_vpn_ips
}

output "hub_to_spoke_tunnels" {
  description = "A map of spoke names to VPN tunnel resources from hub to spokes."
  value       = google_compute_vpn_tunnel.hub_to_spoke_tunnels
}

output "spoke_to_hub_tunnels" {
  description = "A map of spoke names to VPN tunnel resources from spokes to hub."
  value       = google_compute_vpn_tunnel.spoke_to_hub_tunnels
}

output "hub_router_interfaces" {
  description = "A map of spoke names to router interface resources in the hub network."
  value       = google_compute_router_interface.hub_router_interfaces
}

output "hub_router_peers" {
  description = "A map of spoke names to BGP peer resources in the hub network."
  value       = google_compute_router_peer.hub_router_peers
}

output "spoke_router_interfaces" {
  description = "A map of spoke names to router interface resources in spoke networks."
  value       = google_compute_router_interface.spoke_router_interfaces
}

output "spoke_router_peers" {
  description = "A map of spoke names to BGP peer resources in spoke networks."
  value       = google_compute_router_peer.spoke_router_peers
}

output "vpn_tunnels" {
  description = "A map of all VPN tunnel resources."
  value = {
    hub_to_spoke = google_compute_vpn_tunnel.hub_to_spoke_tunnels
    spoke_to_hub = google_compute_vpn_tunnel.spoke_to_hub_tunnels
  }
}

output "vpn_gateways" {
  description = "A map of all VPN gateway resources."
  value = {
    hub    = google_compute_vpn_gateway.hub_gateway
    spokes = google_compute_vpn_gateway.spoke_gateways
  }
}