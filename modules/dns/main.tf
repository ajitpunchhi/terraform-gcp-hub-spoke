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
  
  # Create a map for DNS forwarding zones
  dns_forwarding_zones_map = var.dns_forwarding_zones
}

# Create private DNS zone
resource "google_dns_managed_zone" "private_zone" {
  name        = var.dns_zone_name
  dns_name    = var.dns_domain
  description = "Private DNS zone for Hub and Spoke architecture"
  project     = var.project_id
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = var.hub_network.self_link
    }
    
    dynamic "networks" {
      for_each = local.spoke_networks_map
      content {
        network_url = networks.value.self_link
      }
    }
  }
}

# Create DNS peering zones if specified
resource "google_dns_managed_zone" "dns_peering_zones" {
  for_each = toset(var.dns_peering_zones)
  
  name        = "peering-${replace(var.dns_zone_name, ".", "-")}-to-${each.key}"
  dns_name    = each.key
  description = "DNS peering zone for ${each.key} in Hub and Spoke architecture"
  project     = var.project_id
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = var.hub_network.self_link
    }
    
    dynamic "networks" {
      for_each = local.spoke_networks_map
      content {
        network_url = networks.value.self_link
      }
    }
  }
}

# Create DNS forwarding zones if specified
resource "google_dns_managed_zone" "dns_forwarding_zones" {
  for_each = local.dns_forwarding_zones_map
  
  name        = "forwarding-${replace(each.key, ".", "-")}"
  dns_name    = each.key
  description = "DNS forwarding zone for ${each.key} in Hub and Spoke architecture"
  project     = var.project_id
  
  visibility = "private"
  
  private_visibility_config {
    networks {
      network_url = var.hub_network.self_link
    }
    
    dynamic "networks" {
      for_each = local.spoke_networks_map
      content {
        network_url = networks.value.self_link
      }
    }
  }
  
  forwarding_config {
    dynamic "target_name_servers" {
      for_each = toset(each.value)
      content {
        ipv4_address = target_name_servers.value
      }
    }
  }
}

# Create Cloud DNS inbound DNS policy if enabled
resource "google_dns_policy" "inbound_policy" {
  count = var.enable_inbound_dns ? 1 : 0
  
  name        = "dns-inbound-policy"
  description = "Inbound DNS forwarding policy for Hub and Spoke architecture"
  project     = var.project_id
  
  enable_inbound_forwarding = true
  
  networks {
    network_url = var.hub_network.self_link
  }
}