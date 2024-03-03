
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
The configurations here are intended for Ubuntu 20.04. Start by updating the package manager:
```bash
sudo apt update
```
For each server, you'll need to install:
- Docker
    ```
    sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    sudo docker run hello-world

    sudo usermod -aG docker $USER
    newgrp docker
    docker --version
    ```
- Docker Compose
    ```
    sudo apt-get install docker-compose
    ```
- Create a shared network for the services:
    ```bash
    docker network create shared-network
    ```
 
## Installation Guides
- **Miners and Indexers**: 
  - Funds Flow Model
    - [Bitcoin Indexer and Miner](miners/bitcoin/funds_flow/INSTALLATION.md)
- **Validator Installation**: 
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


