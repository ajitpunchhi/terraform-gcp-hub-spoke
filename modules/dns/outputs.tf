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

output "dns_zone" {
  description = "The private DNS zone resource."
  value       = google_dns_managed_zone.private_zone
}

output "dns_zone_id" {
  description = "The ID of the private DNS zone."
  value       = google_dns_managed_zone.private_zone.id
}

output "dns_zone_name" {
  description = "The name of the private DNS zone."
  value       = google_dns_managed_zone.private_zone.name
}

output "dns_zone_dns_name" {
  description = "The DNS domain name of the private DNS zone."
  value       = google_dns_managed_zone.private_zone.dns_name
}

output "dns_peering_zones" {
  description = "A map of DNS peering zone resources."
  value       = google_dns_managed_zone.dns_peering_zones
}

output "dns_forwarding_zones" {
  description = "A map of DNS forwarding zone resources."
  value       = google_dns_managed_zone.dns_forwarding_zones
}

output "dns_inbound_policy" {
  description = "The DNS inbound policy resource (if created)."
  value       = var.enable_inbound_dns ? google_dns_policy.inbound_policy[0] : null
}