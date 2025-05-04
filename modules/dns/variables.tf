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

variable "project_id" {
  description = "The project ID where resources will be created."
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the private DNS zone to create."
  type        = string
  default     = "internal"
}

variable "dns_domain" {
  description = "The DNS domain name to use for the private DNS zone. Must end with a period."
  type        = string
  default     = "internal.example.com."
  
  validation {
    condition     = endswith(var.dns_domain, ".")
    error_message = "The dns_domain value must end with a period."
  }
}

variable "hub_network" {
  description = "The hub VPC network resource."
  type        = any
}

variable "spoke_networks" {
  description = "A map of spoke names to VPC network resources."
  type        = map(any)
}

variable "dns_peering_zones" {
  description = "A list of DNS peering zone domain names to create. Must end with periods."
  type        = list(string)
  default     = []
  
  validation {
    condition     = alltrue([for zone in var.dns_peering_zones : endswith(zone, ".")])
    error_message = "All DNS peering zone domain names must end with a period."
  }
}

variable "dns_forwarding_zones" {
  description = "A map of DNS forwarding zone domain names to a list of target name servers."
  type        = map(list(string))
  default     = {}
  
  validation {
    condition     = alltrue([for zone in keys(var.dns_forwarding_zones) : endswith(zone, ".")])
    error_message = "All DNS forwarding zone domain names must end with a period."
  }
}

variable "enable_inbound_dns" {
  description = "Whether to enable inbound DNS forwarding."
  type        = bool
  default     = false
}