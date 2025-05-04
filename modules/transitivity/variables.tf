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



variable "transitivity_method" {
  description = "The method to use for transitivity between spokes. Valid options are 'nva' (Network Virtual Appliance) or 'ncc_mesh' (Network Connectivity Center mesh topology)."
  type        = string
  default     = "ncc_mesh"
  
  validation {
    condition     = contains(["nva", "ncc_mesh"], var.transitivity_method)
    error_message = "Valid values for transitivity_method are 'nva' or 'ncc_mesh'."
  }
}

variable "hub_network" {
  description = "The hub VPC network resource."
  type        = any
}

variable "hub_subnets" {
  description = "A map of subnet names to subnet resources in the hub VPC."
  type        = map(any)
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

variable "ncc_hub" {
  description = "The Network Connectivity Center hub resource (if using NCC)."
  type        = any
  default     = null
}

# Variables specific to the NVA method
variable "nva_subnet_cidr" {
  description = "The CIDR range for the NVA subnet. Only applicable when transitivity_method is 'nva'."
  type        = string
  default     = ""
}

variable "nva_machine_type" {
  description = "The machine type for the NVA instances. Only applicable when transitivity_method is 'nva'."
  type        = string
  default     = "e2-medium"
}

variable "nva_instance_count" {
  description = "The number of NVA instances to create. Only applicable when transitivity_method is 'nva'."
  type        = number
  default     = 2
}

variable "nva_zones" {
  description = "The zones to create NVA instances in. Only applicable when transitivity_method is 'nva'."
  type        = list(string)
  default     = ["a", "b"]
}

variable "nva_image" {
  description = "The image to use for the NVA instances. Only applicable when transitivity_method is 'nva'."
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "nva_boot_disk_size" {
  description = "The boot disk size for the NVA instances. Only applicable when transitivity_method is 'nva'."
  type        = number
  default     = 20
}

variable "nva_boot_disk_type" {
  description = "The boot disk type for the NVA instances. Only applicable when transitivity_method is 'nva'."
  type        = string
  default     = "pd-standard"
}

variable "nva_assign_external_ip" {
  description = "Whether to assign an external IP to the NVA instances. Only applicable when transitivity_method is 'nva'."
  type        = bool
  default     = false
}

variable "nva_startup_script_path" {
  description = "The path to the startup script for the NVA instances. Only applicable when transitivity_method is 'nva'."
  type        = string
  default     = "scripts/nva_startup.sh"
}