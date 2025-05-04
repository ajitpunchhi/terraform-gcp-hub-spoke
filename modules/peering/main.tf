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
  peering_map = {
    for name, spoke in var.spoke_networks :
    name => {
      project_id   = spoke.project_id
      network_name = spoke.network_name
      network      = spoke.network
    }
  }
}

# Create peering connection from hub to spoke
resource "google_compute_network_peering" "hub_to_spoke" {
  for_each = local.peering_map
  
  name                                = "hub-to-${each.key}"
  network                             = var.hub_network.self_link
  peer_network                        = each.value.network.self_link
  export_custom_routes                = var.export_routes
  import_custom_routes                = var.import_routes
  export_subnet_routes_with_public_ip = var.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = var.import_subnet_routes_with_public_ip
  
  depends_on = [var.hub_network, each.value.network]
}

# Create peering connection from spoke to hub
resource "google_compute_network_peering" "spoke_to_hub" {
  for_each = local.peering_map
  
  name                                = "${each.key}-to-hub"
  network                             = each.value.network.self_link
  peer_network                        = var.hub_network.self_link
  export_custom_routes                = var.export_routes
  import_custom_routes                = var.import_routes
  export_subnet_routes_with_public_ip = var.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = var.import_subnet_routes_with_public_ip
  
  depends_on = [var.hub_network, each.value.network, google_compute_network_peering.hub_to_spoke[each.key]]
}