/**
 * # Variables for Network Connectivity Center Example
 */

variable "project_id" {
  description = "The project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The region where resources will be created."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "The environment name (e.g., dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "enable_transitivity" {
  description = "Whether to enable transitivity between spokes (mesh topology)."
  type        = bool
  default     = true
}

variable "enable_onprem_connectivity" {
  description = "Whether to enable connectivity to on-premises networks."
  type        = bool
  default     = false
}

variable "onprem_cidr_ranges" {
  description = "A list of CIDR ranges for on-premises networks."
  type        = list(string)
  default     = ["172.16.0.0/16"]
}

variable "onprem_connection_type" {
  description = "The type of connection to use for on-premises connectivity."
  type        = string
  default     = "vpn"
  
  validation {
    condition     = contains(["vpn", "interconnect"], var.onprem_connection_type)
    error_message = "Valid values for onprem_connection_type are 'vpn' or 'interconnect'."
  }
}

variable "vpn_shared_secret" {
  description = "The shared secret to use for VPN tunnel to on-premises."
  type        = string
  default     = ""
  sensitive   = true
}

variable "vpn_gateway_ip" {
  description = "The IP address of the on-premises VPN gateway."
  type        = string
  default     = ""
}

variable "create_test_vms" {
  description = "Whether to create test VMs in the hub and spoke networks."
  type        = bool
  default     = false
}