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

variable "hub_project_id" {
  description = "The project ID where the hub network is created."
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
  }))
}

variable "export_routes" {
  description = "Whether to export custom routes when peering."
  type        = bool
  default     = true
}

variable "import_routes" {
  description = "Whether to import custom routes when peering."
  type        = bool
  default     = true
}

variable "export_subnet_routes_with_public_ip" {
  description = "Whether to export routes with public IP when peering."
  type        = bool
  default     = false
}

variable "import_subnet_routes_with_public_ip" {
  description = "Whether to import routes with public IP when peering."
  type        = bool
  default     = false
}