Google Cloud Platform Hub and Spoke Network Architecture Terraform Module
This Terraform module implements a flexible and production-ready Hub and Spoke network architecture in Google Cloud Platform (GCP). It provides a modular approach that supports different connectivity models and offers extensive customization options for enterprise deployments.
Architecture Overview
The Hub and Spoke architecture is a network topology where a central hub VPC connects to multiple spoke VPCs. This topology offers several advantages:

Centralized connectivity: Shared resources and services in the hub network
Workload isolation: Separate spoke networks for different environments or applications
Simplified management: Centralized control over network connectivity
Enhanced security: Consistent implementation of security controls

This module supports three connectivity models:

VPC Peering: High-bandwidth, low-latency connectivity using direct VPC peering
Network Connectivity Center (NCC): Centralized management with star or mesh topology
Cloud VPN: IPsec VPN tunnels with transitive routing

Features

Complete hub and spoke network configuration
Multiple connectivity options (VPC Peering, NCC, VPN)
Automatic subnet creation and CIDR allocation
Cloud NAT for egress internet traffic
Private DNS configuration with DNS forwarding
Support for on-premises connectivity (VPN, Interconnect)
Optional transitivity between spokes
Baseline firewall rules and security controls
Modular design for easy customization
Consistent naming and tagging conventions
Comprehensive documentation and examples

Usage
hclmodule "hub_spoke_network" {
  source  = "github.com/yourusername/terraform-gcp-hub-spoke"
  version = "1.0.0"
  
  # General settings
  project_id      = "my-project-id"
  region          = "us-central1"
  
  # Hub network configuration
  hub_network_name = "hub-network"
  hub_subnets = [
    {
      name          = "hub-subnet-1"
      ip_cidr_range = "10.0.0.0/24"
      region        = "us-central1"
    }
  ]
  
  # Spoke networks configuration
  spoke_networks = [
    {
      name          = "spoke-1"
      network_name  = "spoke-network-1"
      subnets = [
        {
          name          = "spoke-subnet-1"
          ip_cidr_range = "10.1.0.0/24"
          region        = "us-central1"
        }
      ]
    },
    {
      name          = "spoke-2"
      network_name  = "spoke-network-2"
      subnets = [
        {
          name          = "spoke-subnet-2"
          ip_cidr_range = "10.2.0.0/24"
          region        = "us-central1"
        }
      ]
    }
  ]
  
  # Connection type (choose one: "vpc_peering", "ncc", "vpn")
  connection_type = "vpc_peering"
  
  # Optional features
  enable_cloud_nat = true
  enable_private_dns = true
  dns_domain = "internal.example.com."
}
Module Structure
terraform-gcp-hub-spoke/
├── README.md
├── examples/
│   ├── basic-vpc-peering/        # Simple hub and spoke with VPC peering
│   ├── network-connectivity-center/ # Hub and spoke with NCC
│   └── vpn-connectivity/         # Hub and spoke with VPN tunnels
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── hub/                      # Hub network resources
│   ├── spoke/                    # Spoke network resources
│   ├── ncc/                      # Network Connectivity Center
│   ├── peering/                  # VPC Peering connectivity
│   ├── vpn/                      # VPN connectivity
│   ├── dns/                      # DNS configuration
│   ├── transitivity/             # Transitivity between spokes
│   └── onprem_connectivity/      # On-premises connectivity
└── scripts/
    └── nva_startup.sh            # Startup script for Network Virtual Appliances
Network Connectivity Options
VPC Peering
hclconnection_type = "vpc_peering"
VPC Network Peering is a simple, high-bandwidth, low-latency connectivity option that allows resources in different VPC networks to communicate using their internal IP addresses. This option is suitable for:

Small to medium deployments
Scenarios where transitivity between spokes is not required
Direct communication between hub and spoke resources

Limitations:

Non-transitive connectivity
25 peers per VPC limit
Cannot use the same IP ranges

Network Connectivity Center
hclconnection_type = "ncc"
ncc_topology    = "star"  # or "mesh" for spoke-to-spoke connectivity
Network Connectivity Center provides a centralized management plane for network connectivity. It supports both star (hub-and-spoke) and mesh topologies. This option is suitable for:

Large enterprise deployments
Complex multi-region architectures
Hybrid cloud environments
Scenarios requiring transitivity

Benefits:

Dynamic route propagation
Transitive connectivity with mesh topology
Scalable architecture

Cloud VPN
hclconnection_type = "vpn"
Cloud VPN uses IPsec tunnels to create secure connections between networks. This option is suitable for:

Scenarios requiring transitive routing
Environments with stringent security requirements
Connections between different cloud providers
When VPC peering limits are reached

Benefits:

Transitive connectivity
End-to-end encryption
Overcomes VPC peering limitations

Transitivity Between Spokes
The module supports two methods for enabling communication between spoke networks:

Network Connectivity Center Mesh (recommended):

hclenable_transitivity = true
transitivity_method = "ncc_mesh"

Network Virtual Appliance (NVA):

hclenable_transitivity = true
transitivity_method = "nva"
On-premises Connectivity
The module provides options for connecting to on-premises networks:
Cloud VPN
hclenable_onprem_connectivity = true
onprem_connection_type     = "vpn"
onprem_cidr_ranges         = ["172.16.0.0/16"]
vpn_gateway_ip             = "203.0.113.1"
vpn_shared_secret          = "your-shared-secret"
Cloud Interconnect
hclenable_onprem_connectivity = true
onprem_connection_type     = "interconnect"
onprem_cidr_ranges         = ["172.16.0.0/16"]
interconnect_attachments   = [
  {
    name                     = "interconnect-attachment-1"
    region                   = "us-central1"
    edge_availability_domain = "availability-domain-1"
  },
  {
    name                     = "interconnect-attachment-2"
    region                   = "us-central1"
    edge_availability_domain = "availability-domain-2"
  }
]
DNS Configuration
The module automatically configures private DNS zones and forwarding:
hclenable_private_dns   = true
dns_zone_name        = "internal"
dns_domain           = "internal.example.com."
dns_forwarding_zones = {
  "onprem.example.com." = ["10.100.0.1", "10.100.0.2"]
}
Examples
VPC Peering Example
See examples/basic-vpc-peering for a complete example using VPC Peering.
Network Connectivity Center Example
See examples/network-connectivity-center for a complete example using Network Connectivity Center.
Cloud VPN Example
See examples/vpn-connectivity for a complete example using Cloud VPN.
Requirements
NameVersionterraform>= 1.0.0google>= 4.50.0, < 5.0.0google-beta>= 4.50.0, < 5.0.0random>= 3.4.0
Providers
NameVersiongoogle>= 4.50.0, < 5.0.0google-beta>= 4.50.0, < 5.0.0random>= 3.4.0
Contributing
Contributions to this module are welcome! Please feel free to submit a pull request.
License
Apache 2.0 - See LICENSE for more information