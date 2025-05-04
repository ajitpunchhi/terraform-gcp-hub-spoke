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

variable "ncc_hub_name" {
  description = "The name of the Network Connectivity Center hub."
  type        = string
  default     = "global-network-hub"
}

variable "ncc_topology" {
  description = "The topology to use for Network Connectivity Center. Valid options are 'star' or 'mesh'."
  type        = string
  default     = "star"
  
  validation {
    condition     = contains(["star", "mesh"], var.ncc_topology)
    error_message = "Valid values for ncc_topology are 'star' or 'mesh'."
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

variable "region" {
  description = "The region to create resources in."
  type        = string
}

variable "spoke_projects" {
  description = "A map of spoke names to project IDs. If not specified, the project_id will be used."
  type        = map(string)
  default     = {}
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

variable "labels" {
  description = "A map of key/value label pairs to assign to the resources."
  type        = map(string)
  default     = {}
}