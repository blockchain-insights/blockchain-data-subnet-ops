#!/bin/bash
# UFW Bash Script for Ubuntu Server
# Reset UFW rules

echo "Resetting UFW rules..."
sudo ufw reset

# Set default policies to allow all incoming and outgoing traffic
echo "Setting default policies to allow all..."
sudo ufw default allow incoming
sudo ufw default allow outgoing

echo "Configuring port access for specific IP..."
sudo ufw allow from YOUR_VPN_IP_ADDRESS to any port 3000
sudo ufw allow from YOUR_VPN_IP_ADDRESS to any port 9999
sudo ufw allow from YOUR_VPN_IP_ADDRESS to any port 9998

# Deny the same ports for all other IPs
echo "Blocking the same ports for all other IPs..."
sudo ufw deny 3000
sudo ufw deny 9998
sudo ufw deny 9999

# Enable UFW
echo "Enabling UFW..."
sudo ufw enable

echo "UFW configuration complete."
