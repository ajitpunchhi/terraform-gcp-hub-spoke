# 🌐 GCP Hub and Spoke Network Architecture

<div align="center">
  
  ![GCP Hub and Spoke](https://raw.githubusercontent.com/ajitpunchhi/terraform-gcp-hub-spoke/main/docs/images/hub-spoke-banner.png)

  [![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
  [![GCP](https://img.shields.io/badge/Google_Cloud-%234285F4.svg?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
  [![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=for-the-badge)](LICENSE)
  [![GitHub Stars](https://img.shields.io/github/stars/ajitpunchhi/terraform-gcp-hub-spoke.svg?style=for-the-badge)](https://github.com/yourusername/terraform-gcp-hub-spoke/stargazers)
  
  **Production-ready Terraform module for implementing enterprise-grade Hub and Spoke networks in Google Cloud Platform**
</div>

## 🌟 Features

<table>
<tr>
<td>

### 🔄 Multiple Connectivity Options
- **VPC Peering** - Direct, high-bandwidth connections
- **Network Connectivity Center** - Centralized management
- **Cloud VPN** - Secure, encrypted tunnels

### 🛡️ Enterprise Security
- Baseline firewall rules
- Security controls
- Private DNS configuration

</td>
<td>

### 🔌 Hybrid Cloud Ready
- On-premises connectivity
- Support for Cloud Interconnect
- Automated IPsec VPN tunnels

### 🧩 Modular Architecture
- Customizable components
- Consistent naming conventions
- Comprehensive documentation

</td>
</tr>
</table>

## 🏗️ Architecture

<div align="center">
  <img src="https://raw.githubusercontent.com/ajitpunchhi/terraform-gcp-hub-spoke/main/docs/images/architecture-diagram.png" alt="Architecture Diagram" width="800"/>
</div>

The Hub and Spoke architecture provides:

- **Centralized connectivity**: Shared resources in the hub network
- **Workload isolation**: Separate spoke networks for different environments
- **Simplified management**: Central control over network connectivity
- **Enhanced security**: Consistent implementation of security controls

## 🚀 Quick Start

```hcl
module "hub_spoke_network" {
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
```

## 🔄 Connectivity Options

### VPC Peering
```hcl
connection_type = "vpc_peering"
```
<details>
<summary>Details</summary>

- Simple, high-bandwidth, low-latency connectivity
- Resources communicate using internal IP addresses
- Ideal for small to medium deployments
- Direct communication between hub and spoke resources
- **Limitations**: Non-transitive, 25 peers per VPC, no duplicate IP ranges
</details>

### Network Connectivity Center
```hcl
connection_type = "ncc"
ncc_topology    = "star"  # or "mesh" for spoke-to-spoke connectivity
```
<details>
<summary>Details</summary>

- Centralized management plane for network connectivity
- Supports both star and mesh topologies
- Ideal for large enterprise deployments
- Benefits: Dynamic route propagation, transitive connectivity with mesh
</details>

### Cloud VPN
```hcl
connection_type = "vpn"
```
<details>
<summary>Details</summary>

- Uses IPsec tunnels for secure connections
- Enables transitive routing
- Ideal for environments with stringent security requirements
- Overcomes VPC peering limitations
- Benefits: End-to-end encryption
</details>

## 🌍 On-premises Connectivity

### Cloud VPN
```hcl
enable_onprem_connectivity = true
onprem_connection_type     = "vpn"
onprem_cidr_ranges         = ["172.16.0.0/16"]
vpn_gateway_ip             = "203.0.113.1"
vpn_shared_secret          = "your-shared-secret"
```

### Cloud Interconnect
```hcl
enable_onprem_connectivity = true
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
```

## 📁 Project Structure

```
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
```

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| google | >= 4.50.0, < 5.0.0 |
| google-beta | >= 4.50.0, < 5.0.0 |
| random | >= 3.4.0 |

## 🔍 Examples

- [**VPC Peering**](examples/basic-vpc-peering/) - Complete example using VPC Peering
- [**Network Connectivity Center**](examples/network-connectivity-center/) - Example using Network Connectivity Center

## 👥 Contributing

Contributions to this module are welcome! Please feel free to submit a pull request.

## 📄 License

Apache 2.0 - See [LICENSE](LICENSE) for more information.

---

<div align="center">
  <p>Made with ❤️ for GCP infrastructure</p>
  <p>
    <a href="https://github.com/ajitpunchhi/terraform-gcp-hub-spoke/issues/new">Report Bug</a>
    ·
    <a href="https://github.com/ajitpunchhi/terraform-gcp-hub-spoke/issues/new">Request Feature</a>
  </p>
</div>
