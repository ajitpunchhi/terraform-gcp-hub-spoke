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

variable "hub_network" {
  description = "The hub VPC network resource."
  type        = any
}

variable "hub_network_name" {
  description = "The name of the hub VPC network."
  type        = string
}

variable "region" {
  description = "The region to create resources in."
  type        = string
}

variable "onprem_cidr_ranges" {
  description = "A list of CIDR ranges for on-premises networks."
  type        = list(string)
  default     = []
}

variable "onprem_connection_type" {
  description = "The type of connection to use for on-premises connectivity. Valid options are 'vpn' or 'interconnect'."
  type        = string
  default     = "vpn"
  
  validation {
    condition     = contains(["vpn", "interconnect"], var.onprem_connection_type)
    error_message = "Valid values for onprem_connection_type are 'vpn' or 'interconnect'."
  }
}

# VPN specific variables
variable "vpn_shared_secret" {
  description = "The shared secret to use for VPN tunnel. If not provided, a random one will be generated."
  type        = string
  default     = ""
  sensitive   = true
}

variable "vpn_gateway_ip" {
  description = "The IP address of the on-premises VPN gateway."
  type        = string
  default     = ""
}

variable "ike_version" {
  description = "The IKE version to use for VPN tunnel."
  type        = number
  default     = 2
  
  validation {
    condition     = contains([1, 2], var.ike_version)
    error_message = "Valid values for ike_version are 1 or 2."
  }
}

# Interconnect specific variables
variable "interconnect_attachments" {
  description = "A list of Dedicated/Partner Interconnect attachments."
  type = list(object({
    name                     = string
    region                   = string
    edge_availability_domain = string
    admin_enabled            = optional(bool, true)
  }))
  default = []
}

# BGP variables
variable "gcp_router_asn" {
  description = "The ASN to use for the GCP Cloud Router."
  type        = number
  default     = 64512
}

variable "onprem_router_asn" {
  description = "The ASN to use for the on-premises router."
  type        = number
  default     = 65000
}

variable "bgp_interface_ip_base" {
  description = "The base IP address for BGP interfaces."
  type        = string
  default     = "169.254.1"
}

variable "gcp_router_advertised_route_priority" {
  description = "The priority of routes advertised by the GCP router."
  type        = number
  default     = 100
}