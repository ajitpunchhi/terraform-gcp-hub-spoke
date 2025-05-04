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

output "transitivity_details" {
  description = "Details of the transitivity implementation."
  value = {
    method = var.transitivity_method
    
    # For NVA method
    nva_subnet = var.transitivity_method == "nva" ? google_compute_subnetwork.nva_subnet[0] : null
    nva_instances = var.transitivity_method == "nva" ? {
      for i in range(var.nva_instance_count) :
      "nva-instance-${i + 1}" => {
        name           = google_compute_instance.nva_instances[i].name
        self_link      = google_compute_instance.nva_instances[i].self_link
        internal_ip    = google_compute_instance.nva_instances[i].network_interface[0].network_ip
        zone           = google_compute_instance.nva_instances[i].zone
        service_account = google_service_account.nva_service_account[0].email
      }
    } : null
    nva_backend_service = var.transitivity_method == "nva" ? google_compute_backend_service.nva_backend_service[0] : null
    nva_routes = var.transitivity_method == "nva" ? google_compute_route.spoke_to_spoke_routes : null
    
    # For NCC mesh method
    ncc_mesh_hub = var.transitivity_method == "ncc_mesh" ? google_network_connectivity_hub.mesh_hub[0] : null
    ncc_mesh_spokes = var.transitivity_method == "ncc_mesh" ? merge(
      { "hub" = google_network_connectivity_spoke.mesh_hub_spoke[0] },
      { for name, spoke in google_network_connectivity_spoke.mesh_spoke_spokes : name => spoke }
    ) : null
  }
}

output "nva_subnet" {
  description = "The NVA subnet resource (if using NVA)."
  value       = var.transitivity_method == "nva" ? google_compute_subnetwork.nva_subnet[0] : null
}

output "nva_instances" {
  description = "A map of NVA instance names to resources (if using NVA)."
  value = var.transitivity_method == "nva" ? {
    for i in range(var.nva_instance_count) :
    "nva-instance-${i + 1}" => google_compute_instance.nva_instances[i]
  } : null
}

output "nva_service_account" {
  description = "The service account for NVA instances (if using NVA)."
  value       = var.transitivity_method == "nva" ? google_service_account.nva_service_account[0] : null
}

output "nva_backend_service" {
  description = "The backend service for NVA instances (if using NVA)."
  value       = var.transitivity_method == "nva" ? google_compute_backend_service.nva_backend_service[0] : null
}

output "nva_health_check" {
  description = "The health check for NVA instances (if using NVA)."
  value       = var.transitivity_method == "nva" ? google_compute_health_check.nva_health_check[0] : null
}

output "spoke_to_spoke_routes" {
  description = "A map of routes for spoke-to-spoke communication (if using NVA)."
  value       = var.transitivity_method == "nva" ? google_compute_route.spoke_to_spoke_routes : null
}

output "ncc_mesh_hub" {
  description = "The Network Connectivity Center hub resource with mesh topology (if using NCC mesh)."
  value       = var.transitivity_method == "ncc_mesh" ? google_network_connectivity_hub.mesh_hub[0] : null
}

output "ncc_mesh_spokes" {
  description = "A map of Network Connectivity Center spoke resources in mesh topology (if using NCC mesh)."
  value = var.transitivity_method == "ncc_mesh" ? merge(
    { "hub" = google_network_connectivity_spoke.mesh_hub_spoke[0] },
    google_network_connectivity_spoke.mesh_spoke_spokes
  ) : null
}