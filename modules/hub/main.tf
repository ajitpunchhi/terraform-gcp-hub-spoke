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
  # Create a map of subnets for easier reference
  subnets_map = {
    for subnet in var.subnets :
    subnet.name => subnet
  }
  
  # Determine if Cloud NAT should be enabled
  enable_nat = var.enable_cloud_nat
  
  # Create a map of regions for Cloud NAT (if enabled)
  regions = distinct([
    for subnet in var.subnets :
    subnet.region
  ])
  
  # Default firewall rules to create
  default_firewall_rules = {
    "allow-internal" = {
      name          = "${var.network_name}-allow-internal"
      description   = "Allow internal traffic between instances in the hub network"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = [for subnet in var.subnets : subnet.ip_cidr_range]
      allow = [{
        protocol = "all"
        ports    = []
      }]
    },
    "allow-health-checks" = {
      name          = "${var.network_name}-allow-health-checks"
      description   = "Allow Google health check probes"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
      allow = [{
        protocol = "tcp"
        ports    = []
      }]
    }
  }
}

# Create the VPC network
resource "google_compute_network" "hub_network" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  mtu                     = var.mtu
  description             = "Hub VPC network for Hub and Spoke architecture"
  
  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = lookup(timeouts.value, "create", null)
      update = lookup(timeouts.value, "update", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }
}

# Create subnets in the VPC
resource "google_compute_subnetwork" "subnets" {
  for_each      = local.subnets_map
  
  project       = var.project_id
  name          = each.key
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.hub_network.id
  
  private_ip_google_access = lookup(each.value, "private_ip_google_access", true)
  purpose                  = lookup(each.value, "purpose", null)
  role                     = lookup(each.value, "role", null)
  
  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ip_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
  
  dynamic "log_config" {
    for_each = var.subnet_log_config != null ? [var.subnet_log_config] : []
    content {
      aggregation_interval = lookup(log_config.value, "aggregation_interval", "INTERVAL_5_SEC")
      flow_sampling        = lookup(log_config.value, "flow_sampling", 0.5)
      metadata             = lookup(log_config.value, "metadata", "INCLUDE_ALL_METADATA")
    }
  }
}

# Create default firewall rules
resource "google_compute_firewall" "default_rules" {
  for_each      = var.create_default_firewall_rules ? local.default_firewall_rules : {}
  
  project       = var.project_id
  name          = each.value.name
  network       = google_compute_network.hub_network.id
  description   = each.value.description
  direction     = each.value.direction
  priority      = each.value.priority
  source_ranges = lookup(each.value, "source_ranges", null)
  target_tags   = lookup(each.value, "target_tags", null)
  
  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", [])
    }
  }
}

# Create Cloud NAT resources if enabled
resource "google_compute_router" "nat_router" {
  for_each    = local.enable_nat ? toset(local.regions) : []
  
  name        = "${var.network_name}-nat-router-${each.value}"
  project     = var.project_id
  region      = each.value
  network     = google_compute_network.hub_network.id
  description = "Router for Cloud NAT in the hub network"
}

resource "google_compute_address" "nat_address" {
  for_each     = local.enable_nat ? toset(local.regions) : []
  
  name         = "${var.network_name}-nat-ip-${each.value}"
  project      = var.project_id
  region       = each.value
  address_type = "EXTERNAL"
  description  = "External IP address for Cloud NAT in the hub network"
}

resource "google_compute_router_nat" "nat" {
  for_each                           = local.enable_nat ? toset(local.regions) : []
  
  name                               = "${var.network_name}-nat-${each.value}"
  project                            = var.project_id
  router                             = google_compute_router.nat_router[each.value].name
  region                             = each.value
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_address[each.value].self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}