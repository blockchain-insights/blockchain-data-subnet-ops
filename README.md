
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

## Bittensor and wallet creation
You will also need to [install Bittensor](https://docs.bittensor.com/getting-started/installation) and create or import wallets.
The easiest way to install bittensor is via the following command:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/opentensor/bittensor/master/scripts/install.sh)"
```
You can then create new coldkey and hotkey:
```bash
btcli w new_coldkey
btcli w new_hotkey
```
Or import them:
```bash
btcli w regen_coldkey
btcli w regen_hotkey
```
For more information you can refer to the Bittensor [documentation](https://docs.bittensor.com/getting-started/wallets).

## Installation Guides
- **Miners and Indexers**: 
  - Funds Flow Model
    - [Bitcoin Indexer and Miner](miners/bitcoin-funds-flow/)
- **Validators**: 
  - [Validator Installation Guide](validator/INSTALLATION.md)

## Server Hosting Options
Consider these providers for server hosting:
- [Contabo](https://contabo.com/en/dedicated-servers/)
- [Hetzner](https://www.hetzner.com/dedicated-rootserver/matrix-ax)