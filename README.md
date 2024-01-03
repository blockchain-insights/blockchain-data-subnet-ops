
# Blockchain Data Subnet Operations

Welcome to the Blockchain Data Subnet Operations repository. This repository hosts Docker configurations and scripts for running a variety of blockchain nodes, indexers, subnet miners and validators.

## Table of Contents
- [Introduction](#introduction)
- [System Prerequisites](#system-prerequisites)
- [Installation Guides](#installation-guides) 
- [Server Hosting Options](#server-hosting-options)
- [Updating Container Images](#updating-container-images)


## Introduction
This repository contains Docker Compose files for miners, indexers, validators, nodes, and databases, along with comprehensive installation manuals. 

## System Prerequisites

For each server, you will need to install Docker.

You can find install instructions for [CentOS](https://docs.docker.com/engine/install/centos/#install-using-the-repository), [Debian](https://docs.docker.com/engine/install/debian/#install-using-the-repository), [Fedora](https://docs.docker.com/engine/install/fedora/#install-using-the-repository) and [more](https://docs.docker.com/engine/install/).

The example below is from the install instructions for ***[Ubuntu](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)***.

1. Add Docker's official GPG key:
```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
2. Add the repository to Apt sources:
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
3. Install the Docker packages.
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
4. If you want to run Docker as a non-root user
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```
5. Verify that the Docker Engine installation is successful
```bash
docker run hello-world
```

## Installation Guides
- **Miners and Indexers**: 
  - Funds Flow Model
    - [Bitcoin Indexer and Miner](miners/bitcoin/funds_flow/INSTALLATION.md)
- **Validators**: 
  - [Validator Installation Guide](validator/INSTALLATION.md)

## Server Hosting Options
Consider these providers for server hosting:
- [Contabo](https://contabo.com/en/dedicated-servers/)
- [Hetzner](https://www.hetzner.com/dedicated-rootserver/matrix-ax)

## Updating Container Images
To update container images:
1. Check the latest version at `https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base`.
2. Navigate to the cloned `blockchain-data-subnet-ops` directory.
3. Update your setup:
   ```bash
   git pull
   docker pull ghcr.io/blockchain-insights/blockchain_insights_base:<version>
   docker pull ghcr.io/blockchain-insights/blockchain_insights_base:latest
   ```
   Replace `<version>` with the current version number.
4. Modify `.env` files if necessary (updates announced on Discord).
5. Navigate to the miner or validator directory based on the service you operate.
6. Restart containers with `docker-compose up -d`.


