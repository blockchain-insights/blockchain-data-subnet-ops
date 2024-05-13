
# Blockchain Data Subnet Operations

Welcome to the Blockchain Data Subnet Operations repository. This repository hosts Docker configurations and scripts for running a variety of blockchain nodes, indexers, subnet miners and validators.

## Table of Contents
- [Blockchain Data Subnet Operations](#blockchain-data-subnet-operations)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [System Prerequisites](#system-prerequisites)
    - [Install Docker Loki Plugin](#install-docker-loki-plugin)
    - [Docker Loki Plugin UPGRADE Procedure](#docker-loki-plugin-upgrade-procedure)
  - [Bittensor and wallet creation](#bittensor-and-wallet-creation)
  - [Installation Guides](#installation-guides)


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

### Install Docker Loki Plugin

To improve the subnet you can send telemery and logs accessible only to the subnet 15 team by installing the Docker Loki Pluging. By monitoring the subnet efficiency and errors we can be pro-active by detecting issues promptly.

> [!NOTE] We don't collect sensible information like usersname or passwords.

> Documentation Reference: [Grafana Loki Plugin Documentation](https://grafana.com/docs/loki/latest/send-data/docker-driver/)

1. Docker command to install Plugin

```bash
docker plugin install grafana/loki-docker-driver:2.9.8 --alias loki --grant-all-permissions
```

2. Verify that the Docker Plugin is installed

```bash
docker plugin ls
```

Expected output:
```
ID                  NAME         DESCRIPTION           ENABLED
ac720b8fcfdb        loki         Loki Logging Driver   true
```

>[!WARNING] To take effect you need to restart the Docker daemon, this will shutdown all docker compose services and restart them.

```bash
sudo systemctl restart docker
```
   
### Docker Loki Plugin UPGRADE Procedure

- When a new version of the plugin driver is available you can use theses commands to upgrade the driver
>[!NOTE] Change the version number for the latest, use version number ie: 2.9.10 
> DO NOT USE `main` is a development branch
>
>See the latest version on [Docker Hub Loki Pluging Repository](https://hub.docker.com/r/grafana/loki-docker-driver/tags)

```bash
docker plugin disable loki --force
docker plugin upgrade loki grafana/loki-docker-driver:2.9.8 --grant-all-permissions
docker plugin enable loki
```
> [!WARNING] To take effect you need to restart the Docker daemon, this will terminate all services and restart them. We suggest to do this only when there is a scheduled upgrade and the registrations is disabled not to be affected by the uptime time scoring.

```bash
sudo systemctl restart docker
```

---

## Bittensor and wallet creation
You will also need to [install Bittensor](https://docs.bittensor.com/getting-started/installation) and create or import wallets.
The easiest way to install bittensor is via the following command:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/opentensor/bittensor/master/scripts/install.sh)"
```
if "error: externally-managed-environment" occures to you
run: 
```bash
sudo mv /usr/lib/python3.11/EXTERNALLY-MANAGED /usr/lib/python3.11/EXTERNALLY-MANAGED.old
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
  - [Validator Installation Guide](validator/)
