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

output "peering_connections" {
  description = "A map of all VPC peering connections created."
  value = {
    hub_to_spoke = google_compute_network_peering.hub_to_spoke
    spoke_to_hub = google_compute_network_peering.spoke_to_hub
  }
}

output "hub_to_spoke_peerings" {
  description = "A map of hub-to-spoke peering connections."
  value       = google_compute_network_peering.hub_to_spoke
}

output "spoke_to_hub_peerings" {
  description = "A map of spoke-to-hub peering connections."
  value       = google_compute_network_peering.spoke_to_hub
}