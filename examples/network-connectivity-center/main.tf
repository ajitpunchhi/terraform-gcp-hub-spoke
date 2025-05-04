/**
 * # Hub and Spoke with Network Connectivity Center Example
 *
 * This example demonstrates how to use the Hub and Spoke Terraform module with Network Connectivity Center.
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
        },
        {
          name          = "${local.env_prefix}spoke-1-subnet-2"
          ip_cidr_range = "10.1.1.0/24"
          region        = var.region
          secondary_ip_ranges = [
            {
              range_name    = "pods"
              ip_cidr_range = "192.168.0.0/22"
            },
            {
              range_name    = "services"
              ip_cidr_range = "192.168.4.0/24"
            }
          ]
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
  connection_type = "ncc"
  
  # Network Connectivity Center settings
  ncc_hub_name = "${local.env_prefix}global-network-hub"
  ncc_topology = var.enable_transitivity ? "mesh" : "star"
  
  # Enable Cloud NAT for internet access
  enable_cloud_nat = true
  
  # DNS settings
  enable_private_dns = true
  dns_zone_name      = "${local.env_prefix}internal"
  dns_domain         = "internal.example.com."
  
  # On-premises connectivity
  enable_onprem_connectivity = var.enable_onprem_connectivity
  onprem_cidr_ranges         = var.onprem_cidr_ranges
  onprem_connection_type     = var.onprem_connection_type
  vpn_shared_secret          = var.vpn_shared_secret
  vpn_gateway_ip             = var.vpn_gateway_ip
  
  # Enable transitivity between spokes
  enable_transitivity = var.enable_transitivity
  transitivity_method = "ncc_mesh"
  
  # Labels
  labels = {
    environment = var.environment
    terraform   = "true"
    example     = "ncc"
  }
}

# Optional: Create a sample VM in the hub network for testing
resource "google_compute_instance" "hub_vm" {
  count        = var.create_test_vms ? 1 : 0
  
  name         = "${local.env_prefix}hub-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  project      = var.project_id
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network    = module.hub_spoke_network.hub_network_name
    subnetwork = keys(module.hub_spoke_network.hub_subnets)[0]
  }
  
  metadata_startup_script = "apt-get update && apt-get install -y tcpdump traceroute iperf3 net-tools"
  
  service_account {
    scopes = ["cloud-platform"]
  }
  
  tags = ["hub-vm", "allow-ssh"]
}

# Optional: Create sample VMs in spoke networks for testing
resource "google_compute_instance" "spoke_vms" {
  for_each     = var.create_test_vms ? toset(["spoke-1", "spoke-2"]) : []
  
  name         = "${local.env_prefix}${each.key}-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  project      = var.project_id
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network    = module.hub_spoke_network.spoke_networks_names[each.key]
    subnetwork = keys(module.hub_spoke_network.spoke_subnets[each.key])[0]
  }
  
  metadata_startup_script = "apt-get update && apt-get install -y tcpdump traceroute iperf3 net-tools"
  
  service_account {
    scopes = ["cloud-platform"]
  }
  
  tags = ["spoke-vm", "allow-ssh"]
}

# Create firewall rules for test VMs
resource "google_compute_firewall" "hub_allow_ssh" {
  count       = var.create_test_vms ? 1 : 0
  
  name        = "${local.env_prefix}hub-allow-ssh"
  network     = module.hub_spoke_network.hub_network_name
  project     = var.project_id
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["35.235.240.0/20"] # IAP forwarding range
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "spoke_allow_ssh" {
  for_each     = var.create_test_vms ? toset(["spoke-1", "spoke-2"]) : []
  
  name         = "${local.env_prefix}${each.key}-allow-ssh"
  network      = module.hub_spoke_network.spoke_networks_names[each.key]
  project      = var.project_id
  direction    = "INGRESS"
  priority     = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["35.235.240.0/20"] # IAP forwarding range
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow_icmp" {
  count       = var.create_test_vms ? 1 : 0
  
  name        = "${local.env_prefix}allow-icmp"
  network     = module.hub_spoke_network.hub_network_name
  project     = var.project_id
  direction   = "INGRESS"
  priority    = 1000
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "spoke_allow_icmp" {
  for_each     = var.create_test_vms ? toset(["spoke-1", "spoke-2"]) : []
  
  name         = "${local.env_prefix}${each.key}-allow-icmp"
  network      = module.hub_spoke_network.spoke_networks_names[each.key]
  project      = var.project_id
  direction    = "INGRESS"
  priority     = 1000
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["10.0.0.0/8"]
}