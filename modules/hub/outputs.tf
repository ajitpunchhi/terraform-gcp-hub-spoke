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

output "network" {
  description = "The VPC network resource."
  value       = google_compute_network.hub_network
}

output "network_id" {
  description = "The ID of the VPC network."
  value       = google_compute_network.hub_network.id
}

output "network_name" {
  description = "The name of the VPC network."
  value       = google_compute_network.hub_network.name
}

output "network_self_link" {
  description = "The self-link of the VPC network."
  value       = google_compute_network.hub_network.self_link
}

output "subnets" {
  description = "A map of subnet names to subnet resources."
  value       = google_compute_subnetwork.subnets
}

output "subnets_ids" {
  description = "A map of subnet names to subnet IDs."
  value       = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.id
  }
}

output "subnets_self_links" {
  description = "A map of subnet names to subnet self-links."
  value       = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.self_link
  }
}

output "subnets_regions" {
  description = "A map of subnet names to subnet regions."
  value       = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.region
  }
}

output "subnets_ip_cidr_ranges" {
  description = "A map of subnet names to subnet IP CIDR ranges."
  value       = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.ip_cidr_range
  }
}

output "nat_routers" {
  description = "A map of region names to Cloud NAT routers (if enabled)."
  value       = var.enable_cloud_nat ? google_compute_router.nat_router : {}
}

output "nat_addresses" {
  description = "A map of region names to Cloud NAT external IP addresses (if enabled)."
  value       = var.enable_cloud_nat ? google_compute_address.nat_address : {}
}

output "nat_configs" {
  description = "A map of region names to Cloud NAT configurations (if enabled)."
  value       = var.enable_cloud_nat ? google_compute_router_nat.nat : {}
}

output "firewall_rules" {
  description = "A map of firewall rule names to firewall rule resources (if created)."
  value       = google_compute_firewall.default_rules
}