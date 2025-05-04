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
  # Determine which transitivity method to use
  using_nva = var.transitivity_method == "nva"
  using_ncc_mesh = var.transitivity_method == "ncc_mesh"
  
  # Create a map for easier reference
  spoke_networks_map = var.spoke_networks
  
  # Get a list of CIDR ranges for all spoke networks
  spoke_cidrs = flatten([
    for name, spoke in local.spoke_networks_map : [
      for subnet in spoke.subnets :
      subnet.ip_cidr_range
    ]
  ])
  
  # Determine a CIDR range for the NVA subnet (only used if using_nva is true)
  nva_subnet_cidr = var.nva_subnet_cidr != "" ? var.nva_subnet_cidr : "10.0.200.0/24"
}

# If using NVA, create a subnet for the NVA instances
resource "google_compute_subnetwork" "nva_subnet" {
  count         = local.using_nva ? 1 : 0
  
  name          = "nva-subnet"
  project       = var.project_id
  region        = var.region
  network       = var.hub_network.self_link
  ip_cidr_range = local.nva_subnet_cidr
  description   = "Subnet for Network Virtual Appliance instances"
  
  private_ip_google_access = true
}

# If using NVA, create a service account for the NVA instances
resource "google_service_account" "nva_service_account" {
  count        = local.using_nva ? 1 : 0
  
  project      = var.project_id
  account_id   = "nva-service-account"
  display_name = "Network Virtual Appliance Service Account"
  description  = "Service account for Network Virtual Appliance instances"
}

# If using NVA, grant the service account necessary permissions
resource "google_project_iam_member" "nva_compute_network_admin" {
  count   = local.using_nva ? 1 : 0
  
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.nva_service_account[0].email}"
}

# If using NVA, create NVA instances
resource "google_compute_instance" "nva_instances" {
  count = local.using_nva ? var.nva_instance_count : 0
  
  name         = "nva-instance-${count.index + 1}"
  project      = var.project_id
  machine_type = var.nva_machine_type
  zone         = "${var.region}-${var.nva_zones[count.index % length(var.nva_zones)]}"
  
  boot_disk {
    initialize_params {
      image = var.nva_image
      size  = var.nva_boot_disk_size
      type  = var.nva_boot_disk_type
    }
  }
  
  network_interface {
    subnetwork = google_compute_subnetwork.nva_subnet[0].self_link
    
    # If assigning external IP
    dynamic "access_config" {
      for_each = var.nva_assign_external_ip ? [1] : []
      content {
        # Ephemeral IP
      }
    }
  }
  
  can_ip_forward = true
  
  service_account {
    email  = google_service_account.nva_service_account[0].email
    scopes = ["cloud-platform"]
  }
  
  metadata_startup_script = file(var.nva_startup_script_path)
  
  tags = ["nva", "transitivity"]
  
  allow_stopping_for_update = true
}

# If using NVA, create an instance group for load balancing
resource "google_compute_instance_group" "nva_instance_group" {
  count = local.using_nva ? 1 : 0
  
  name        = "nva-instance-group"
  project     = var.project_id
  zone        = "${var.region}-${var.nva_zones[0]}"
  description = "Instance group for Network Virtual Appliance instances"
  
  instances = [
    for i in range(var.nva_instance_count) :
    google_compute_instance.nva_instances[i].self_link
    if "${var.region}-${var.nva_zones[i % length(var.nva_zones)]}" == "${var.region}-${var.nva_zones[0]}"
  ]
  
  named_port {
    name = "http"
    port = 80
  }
  
  named_port {
    name = "https"
    port = 443
  }
}

# If using NVA, create health check for the NVA instances
resource "google_compute_health_check" "nva_health_check" {
  count = local.using_nva ? 1 : 0
  
  name                = "nva-health-check"
  project             = var.project_id
  description         = "Health check for Network Virtual Appliance instances"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  
  tcp_health_check {
    port = 22
  }
}

# If using NVA, create backend service for the NVA instances
resource "google_compute_backend_service" "nva_backend_service" {
  count = local.using_nva ? 1 : 0
  
  name                  = "nva-backend-service"
  project               = var.project_id
  # region attribute removed as it is not supported
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.nva_health_check[0].self_link]
  
  backend {
    group = google_compute_instance_group.nva_instance_group[0].self_link
  }
}

# If using NVA, create routes for spoke-to-spoke communication via the NVA
resource "google_compute_route" "spoke_to_spoke_routes" {
  for_each = local.using_nva ? local.spoke_networks_map : {}
  
  name         = "route-to-${each.key}-via-nva"
  project      = var.project_id
  network      = var.hub_network.self_link
  dest_range   = each.value.subnet_ranges[0]
  priority     = 800
  next_hop_ilb = google_compute_backend_service.nva_backend_service[0].self_link
  
  depends_on = [google_compute_backend_service.nva_backend_service]
}

# If using NCC mesh, update the NCC hub to use mesh topology
resource "google_network_connectivity_hub" "mesh_hub" {
  count = local.using_ncc_mesh ? 1 : 0
  
  provider = google-beta
  
  name        = "mesh-network-hub"
  description = "Network Connectivity Center hub with mesh topology for transitivity"
  project     = var.project_id
  
  # This is a placeholder - in practice, you would update the existing NCC hub
  # to use mesh topology instead of creating a new one.
  # For the purpose of this module, we're creating a new hub to illustrate the concept.
}

# If using NCC mesh, create spoke attachments for all networks in mesh topology
resource "google_network_connectivity_spoke" "mesh_hub_spoke" {
  count = local.using_ncc_mesh ? 1 : 0
  
  provider = google-beta
  
  name        = "hub-vpc-spoke-mesh"
  hub         = google_network_connectivity_hub.mesh_hub[0].id
  location    = "global"
  description = "Hub VPC network spoke in mesh topology"
  project     = var.project_id
  
  linked_vpc_network {
    uri = var.hub_network.self_link
  }
}

resource "google_network_connectivity_spoke" "mesh_spoke_spokes" {
  provider   = google-beta
  for_each   = local.using_ncc_mesh ? local.spoke_networks_map : {}
  
  name        = "${each.key}-vpc-spoke-mesh"
  hub         = google_network_connectivity_hub.mesh_hub[0].id
  location    = "global"
  description = "Spoke VPC network spoke for ${each.key} in mesh topology"
  project     = var.project_id
  
  linked_vpc_network {
    uri = each.value.network.self_link
  }
  
  depends_on = [google_network_connectivity_spoke.mesh_hub_spoke]
}