#!/bin/bash
# Startup script for Network Virtual Appliance (NVA) instances
# This script configures the instance to forward traffic between VPC networks in a Hub and Spoke architecture

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Install necessary packages
sudo apt-get update
sudo apt-get install -y \
    tcpdump \
    iptables-persistent \
    nginx \
    netcat \
    curl \
    net-tools

# Configure iptables for IP forwarding
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT

# Save iptables rules
sudo netfilter-persistent save

# Configure NGINX for health checks
cat << EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    location / {
        return 200 'NVA Health Check: OK\n';
        add_header Content-Type text/plain;
    }
    
    location /health {
        return 200 'NVA Health Check: OK\n';
        add_header Content-Type text/plain;
    }
}
EOF

# Restart NGINX
sudo systemctl restart nginx

# Log the instance metadata
INSTANCE_NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name" 2>/dev/null)
ZONE=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/zone" 2>/dev/null | sed 's/.*zones\///')
INTERNAL_IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip" 2>/dev/null)

echo "NVA instance $INSTANCE_NAME started in zone $ZONE with internal IP $INTERNAL_IP" | sudo tee /var/log/nva-startup.log

# Set up automatic updates
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Complete
echo "NVA configuration complete" | sudo tee -a /var/log/nva-startup.log