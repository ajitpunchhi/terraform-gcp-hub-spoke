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

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "project_id" {
  description = "The project ID for resource deployment. If hub_project_id is not specified, this is also used for the hub."
  type        = string
}

variable "region" {
  description = "The region to create resources in."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ---------------------------------------------------------------------------------------------------------------------

variable "hub_project_id" {
  description = "The project ID for the hub VPC. If not specified, the project_id variable will be used."
  type        = string
  default     = ""
}

variable "hub_network_name" {
  description = "The name of the hub VPC network."
  type        = string
  default     = "hub-network"
}

variable "hub_subnets" {
  description = "A list of subnets to create in the hub VPC network."
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
    private_ip_google_access = optional(bool, true)
    purpose                  = optional(string, "")
    role                     = optional(string, "")
  }))
  default = []
}

variable "spoke_networks" {
  description = "A list of spoke networks to create and connect to the hub."
  type = list(object({
    name          = string
    project_id    = optional(string, null)
    network_name  = string
    subnets = list(object({
      name          = string
      ip_cidr_range = string
      region        = string
      secondary_ip_ranges = optional(list(object({
        range_name    = string
        ip_cidr_range = string
      })), [])
      private_ip_google_access = optional(bool, true)
      purpose                  = optional(string, "")
      role                     = optional(string, "")
    }))
    enable_cloud_nat = optional(bool, false)
  }))
  default = []
}

variable "connection_type" {
  description = "The type of connection to use between hub and spokes. Valid options are 'ncc' (Network Connectivity Center), 'vpc_peering', or 'vpn'."
  type        = string
  default     = "vpc_peering"
  
  validation {
    condition     = contains(["ncc", "vpc_peering", "vpn"], var.connection_type)
    error_message = "Valid values for connection_type are 'ncc', 'vpc_peering', or 'vpn'."
  }
}

variable "ncc_hub_name" {
  description = "The name of the Network Connectivity Center hub. Only applicable when connection_type is 'ncc'."
  type        = string
  default     = "global-network-hub"
}

variable "ncc_topology" {
  description = "The topology to use for Network Connectivity Center. Only applicable when connection_type is 'ncc'. Valid options are 'star' or 'mesh'."
  type        = string
  default     = "star"
  
  validation {
    condition     = contains(["star", "mesh"], var.ncc_topology)
    error_message = "Valid values for ncc_topology are 'star' or 'mesh'."
  }
}

variable "enable_cloud_nat" {
  description = "Whether to enable Cloud NAT on the hub network."
  type        = bool
  default     = false
}

variable "peering_export_custom_routes" {
  description = "Whether to export custom routes when using VPC peering. Only applicable when connection_type is 'vpc_peering'."
  type        = bool
  default     = true
}

variable "peering_import_custom_routes" {
  description = "Whether to import custom routes when using VPC peering. Only applicable when connection_type is 'vpc_peering'."
  type        = bool
  default     = true
}

variable "enable_private_dns" {
  description = "Whether to create private DNS zones."
  type        = bool
  default     = true
}

variable "dns_zone_name" {
  description = "The name of the private DNS zone to create. Only applicable when enable_private_dns is true."
  type        = string
  default     = "internal"
}

variable "dns_domain" {
  description = "The DNS domain name to use for the private DNS zone. Must end with a period. Only applicable when enable_private_dns is true."
  type        = string
  default     = "internal.example.com."
}

variable "dns_forwarding_zones" {
  description = "A map of DNS forwarding zone domain names to a list of target name servers. Only applicable when enable_private_dns is true."
  type        = map(list(string))
  default     = {}
}

variable "enable_transitivity" {
  description = "Whether to enable transitivity between spokes."
  type        = bool
  default     = false
}

variable "transitivity_method" {
  description = "The method to use for transitivity between spokes. Valid options are 'nva' (Network Virtual Appliance) or 'ncc_mesh' (Network Connectivity Center mesh topology)."
  type        = string
  default     = "ncc_mesh"
  
  validation {
    condition     = contains(["nva", "ncc_mesh"], var.transitivity_method)
    error_message = "Valid values for transitivity_method are 'nva' or 'ncc_mesh'."
  }
}

variable "enable_onprem_connectivity" {
  description = "Whether to enable connectivity to on-premises networks."
  type        = bool
  default     = false
}

variable "onprem_cidr_ranges" {
  description = "A list of CIDR ranges for on-premises networks. Only applicable when enable_onprem_connectivity is true."
  type        = list(string)
  default     = []
}

variable "onprem_connection_type" {
  description = "The type of connection to use for on-premises connectivity. Valid options are 'vpn' or 'interconnect'. Only applicable when enable_onprem_connectivity is true."
  type        = string
  default     = "vpn"
  
  validation {
    condition     = contains(["vpn", "interconnect"], var.onprem_connection_type)
    error_message = "Valid values for onprem_connection_type are 'vpn' or 'interconnect'."
  }
}

variable "vpn_shared_secret" {
  description = "The shared secret to use for VPN tunnels. Only applicable when onprem_connection_type is 'vpn'."
  type        = string
  default     = ""
  sensitive   = true
}

variable "vpn_gateway_ip" {
  description = "The IP address of the on-premises VPN gateway. Only applicable when onprem_connection_type is 'vpn'."
  type        = string
  default     = ""
}

variable "interconnect_attachments" {
  description = "A list of Dedicated/Partner Interconnect attachments to use for on-premises connectivity. Only applicable when onprem_connection_type is 'interconnect'."
  type = list(object({
    name     = string
    region   = string
    edge_availability_domain = string
    admin_enabled = optional(bool, true)
  }))
  default = []
}

variable "labels" {
  description = "A map of key/value label pairs to assign to the resources."
  type        = map(string)
  default     = {}
}