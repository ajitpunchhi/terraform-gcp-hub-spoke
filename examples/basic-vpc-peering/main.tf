/**
 * # Basic Hub and Spoke with VPC Peering Example
 *
 * This example demonstrates how to use the Hub and Spoke Terraform module with VPC Peering.
 */

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

locals {
  # Create environment specific names
  env_prefix = var.environment != "" ? "${var.environment}-" : ""
}

# Create the Hub and Spoke network
module "hub_spoke_network" {
  source = "../../"
  
  # General settings
  project_id = var.project_id
  region     = var.region
  
  # Hub network configuration
  hub_network_name = "${local.env_prefix}hub-network"
  hub_subnets = [
    {
      name          = "${local.env_prefix}hub-subnet-1"
      ip_cidr_range = "10.0.0.0/24"
      region        = var.region
    },
    {
      name          = "${local.env_prefix}hub-subnet-2"
      ip_cidr_range = "10.0.1.0/24"
      region        = var.region
    }
  ]
  
  # Spoke networks configuration
  spoke_networks = [
    {
      name          = "${local.env_prefix}spoke-1"
      network_name  = "${local.env_prefix}spoke-network-1"
      subnets = [
        {
          name          = "${local.env_prefix}spoke-1-subnet-1"
          ip_cidr_range = "10.1.0.0/24"
          region        = var.region
        }
      ]
    },
    {
      name          = "${local.env_prefix}spoke-2"
      network_name  = "${local.env_prefix}spoke-network-2"
      subnets = [
        {
          name          = "${local.env_prefix}spoke-2-subnet-1"
          ip_cidr_range = "10.2.0.0/24"
          region        = var.region
        }
      ]
    }
  ]
  
  # Connection type
  connection_type = "vpc_peering"
  
  # VPC Peering settings
  peering_export_custom_routes = true
  peering_import_custom_routes = true
  
  # Enable Cloud NAT on hub
  enable_cloud_nat = true
  
  # DNS settings
  enable_private_dns = true
  dns_zone_name      = "${local.env_prefix}internal"
  dns_domain         = "internal.example.com."
  
  # Labels
  labels = {
    environment = var.environment
    terraform   = "true"
  }
}