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

variable "network_name" {
  description = "The name of the VPC network to create."
  type        = string
  default     = "hub-network"
}

variable "subnets" {
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

variable "region" {
  description = "The default region for resources."
  type        = string
}

variable "routing_mode" {
  description = "The network routing mode (REGIONAL or GLOBAL)."
  type        = string
  default     = "GLOBAL"
  
  validation {
    condition     = contains(["REGIONAL", "GLOBAL"], var.routing_mode)
    error_message = "Valid values for routing_mode are 'REGIONAL' or 'GLOBAL'."
  }
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes."
  type        = number
  default     = 1460
  
  validation {
    condition     = var.mtu >= 1300 && var.mtu <= 8896
    error_message = "The value of mtu must be between 1300 and 8896."
  }
}

variable "timeouts" {
  description = "Custom timeout blocks for resources."
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "subnet_log_config" {
  description = "Configuration for subnet flow logs."
  type = object({
    aggregation_interval = optional(string, "INTERVAL_5_SEC")
    flow_sampling        = optional(number, 0.5)
    metadata             = optional(string, "INCLUDE_ALL_METADATA")
  })
  default = null
}

variable "create_default_firewall_rules" {
  description = "Whether to create default firewall rules for internal communication and health checks."
  type        = bool
  default     = true
}

variable "enable_cloud_nat" {
  description = "Whether to enable Cloud NAT for the network."
  type        = bool
  default     = false
}

variable "labels" {
  description = "A map of key/value label pairs to assign to the resources."
  type        = map(string)
  default     = {}
}