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

output "ncc_hub" {
  description = "The Network Connectivity Center hub resource."
  value       = google_network_connectivity_hub.hub
}

output "ncc_hub_id" {
  description = "The ID of the Network Connectivity Center hub."
  value       = google_network_connectivity_hub.hub.id
}

output "ncc_hub_self_link" {
  description = "The self-link of the Network Connectivity Center hub."
  value       = google_network_connectivity_hub.hub.self_link
}

output "ncc_spokes" {
  description = "A map of all Network Connectivity Center spoke resources."
  value = {
    hub_vpc_spoke = google_network_connectivity_spoke.hub_vpc_spoke
    spoke_vpc_spokes = google_network_connectivity_spoke.spoke_vpc_spokes
  }
}

output "hub_router" {
  description = "The hub network router resource."
  value       = google_compute_router.hub_router
}

output "spoke_routers" {
  description = "A map of spoke names to router resources."
  value       = google_compute_router.spoke_routers
}