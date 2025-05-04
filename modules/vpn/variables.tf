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
  description = "The project ID where hub network resources will be created."
  type        = string
}

variable "hub_network" {
  description = "The hub VPC network resource."
  type        = any
}

variable "hub_network_name" {
  description = "The name of the hub VPC network."
  type        = string
}

variable "spoke_networks" {
  description = "A map of spoke names to network details."
  type = map(object({
    project_id   = string
    network_name = string
    network      = any
    subnets      = map(any)
  }))
}

variable "region" {
  description = "The region to create resources in."
  type        = string
}

variable "vpn_shared_secret" {
  description = "The shared secret to use for VPN tunnels. If not provided, a random one will be generated for each tunnel."
  type        = string
  default     = ""
  sensitive   = true
}

variable "hub_router_asn" {
  description = "The ASN to use for the hub router."
  type        = number
  default     = 64512
}

variable "spoke_router_asn_base" {
  description = "The base ASN to use for spoke routers. Each spoke will get an ASN derived from this base."
  type        = number
  default     = 64513
}

variable "hub_bgp_interface_ip_base" {
  description = "The base IP address for BGP interfaces. Each spoke will get IPs derived from this base."
  type        = string
  default     = "169.254.0"
}

variable "hub_router_advertised_route_priority" {
  description = "The priority of routes advertised by the hub router."
  type        = number
  default     = 100
}

variable "spoke_router_advertised_route_priority" {
  description = "The priority of routes advertised by the spoke routers."
  type        = number
  default     = 100
}

variable "ike_version" {
  description = "The IKE version to use for VPN tunnels."
  type        = number
  default     = 2
  
  validation {
    condition     = contains([1, 2], var.ike_version)
    error_message = "Valid values for ike_version are 1 or 2."
  }
}