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
  
  # Determine if mesh topology is used
  is_mesh = var.ncc_topology == "mesh"
}

# Create NCC hub
resource "google_network_connectivity_hub" "hub" {
  provider = google-beta
  
  name        = var.ncc_hub_name
  description = "Network Connectivity Center hub for Hub and Spoke architecture"
  project     = var.project_id
  labels      = var.labels
}

# Create hub vpc spoke attachment in NCC
resource "google_network_connectivity_spoke" "hub_vpc_spoke" {
  provider = google-beta
  
  name        = "${var.ncc_hub_name}-hub-vpc-spoke"
  hub         = google_network_connectivity_hub.hub.id
  location    = "global"
  description = "Hub VPC network spoke"
  project     = var.project_id
  labels      = var.labels
  
  linked_vpc_network {
    uri = var.hub_network.self_link
  }
}

# Create spoke vpc attachments in NCC
resource "google_network_connectivity_spoke" "spoke_vpc_spokes" {
  provider   = google-beta
  for_each   = local.spoke_networks_map
  
  name        = "${var.ncc_hub_name}-${each.key}-vpc-spoke"
  hub         = google_network_connectivity_hub.hub.id
  location    = "global"
  description = "Spoke VPC network spoke for ${each.key}"
  project     = var.project_id
  labels      = var.labels
  
  linked_vpc_network {
    uri = each.value.self_link
  }
  
  depends_on = [google_network_connectivity_spoke.hub_vpc_spoke]
}

# Create required router in hub network for route exchange
resource "google_compute_router" "hub_router" {
  name        = "${var.ncc_hub_name}-hub-router"
  project     = var.project_id
  region      = var.region
  network     = var.hub_network.self_link
  description = "Router for hub network in NCC configuration"
  
  bgp {
    asn = var.hub_router_asn
  }
}

# Create required routers in spoke networks for route exchange
resource "google_compute_router" "spoke_routers" {
  for_each    = local.spoke_networks_map
  
  name        = "${var.ncc_hub_name}-${each.key}-router"
  project     = lookup(var.spoke_projects, each.key, var.project_id)
  region      = var.region
  network     = each.value.self_link
  description = "Router for ${each.key} spoke network in NCC configuration"
  
  bgp {
    asn = var.spoke_router_asn_base + index(keys(local.spoke_networks_map), each.key)
  }
}