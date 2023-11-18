# Blockchain Data Subnet Operations

Welcome to the Blockchain Data Subnet Operations repository! This repository hosts Docker configurations and scripts for running a variety of blockchain analysis tools and nodes, all aimed at providing in-depth insights into blockchain data and operations.

Table of Contents
=================
  - [Overview](#overview)
  - [Hardware Requirements](#hardware-requirements)
  - [Prerequisites](#prerequisites)
  - [Pre-Installation](#pre-installation)
  - [Docker Compose Configuration](#docker-compose-configuration)
    - [Bitcoin Node](#bitcoin-node)
    - [Subnet Miner and Indexer](#subnet-miner-and-indexer)
    - [Subnet Validator](#subnet-validator)

## Hardware Requirements
The services in this repository are tailored for machines with the following specifications:
- Bitcoin Full Node: 1TB SSD, 64GB RAM, 8 CPU cores
- Subnet Miner and Indexer: 1TB SSD, 256GB RAM, 16 CPU cores
- Subnet Validator: 256GB SSD, 16GB RAM, 4 CPU cores

Recommended Provider: [Scaleway](https://www.scaleway.com/) (Bare Metal Servers)

## Prerequisites
For each server, you'll need to install:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Python 3](https://www.python.org/downloads/)
- [Blockchair](https://blockchair.com/) API Key (cheap for miners, expensive for validators)
 
## Pre-Installation

Clone the repository on each machine using: 

```
git clone https://github.com/blockchain-insights/blockchain-data-subnet-ops
```

The Docker base image for running the subnet miner, indexer, bittensor-cli, and validator is available in the [Registry](https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base). It will automatically download when you run \`docker-compose up -d\` for starting a specific service.

## Docker Compose Configuration

### Bitcoin Node

The code resides in the ```miners/bitcoin-node``` directory of the cloned repository.
Change to this directory and execute 
```
cp .env.example .env
```
Then, edit the file with 
```
nano .env
```
and set the following variables:

#### Variables
```ini
RPC_USER=your_secret_user_name
RPC_PASSWORD=your_secret_password
RPC_ALLOW_IP=Ip address of your miner server
RPC_BIND=network interface to bind to
VERSION=latest
```


To start the Bitcoin node, execute:
```
docker-compose up -d
```
The synchronization of the blockchain will take some time. Monitor the progress with 
```
docker-compose logs -f
```

### Subnet Miner and Indexer

This code is found in the ```miners/funds_flow``` directory of the cloned repository.
Change to this directory and execute 
```
cp .env.example .env
```
Then, edit the file with 
```
nano .env
```
to set the following variables:

#### Variables
```ini
# Version numbers can be found here: https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base
# use the latest version number
VERSION=v0.1.1

# by convention, wallet name should be miner; and the hotkey should be default
# this setting can be skipped as its set in the docker-compose.yml file
WALLET_NAME=miner
WALLET_HOTKEY=default

BLOCKCHAIR_API_KEY=your blockchair key

# Point to the Bitcoin node RPC credentials
NODE_RPC_URL=http://username:password@bitcoin-node:8332 

# this setting can be skipped as its set in the docker-compose.yml file
GRAPH_DB_URL=connection_string_to_memgraph_database

GRAPH_DB_USER=random_string
GRAPH_DB_PASSWORD=random_string

# The following variables are only required for the miner
# Miner waits for 95% sync with the Bitcoin node before starting
WAIT_FOR_SYNC=True
```

To start the miner and indexer, execute 
```
docker-compose up -d
```

Attach to the btcli container with 
```
docker-compose exec btcli bash
``` 
and create a cold and hot keys for the miner wallet with 
```
btcli wallet new_coldkey --wallet.name miner
btcli wallet new_hotkey --wallet.name miner --wallet.hotkey default
```
Remember to store the wallet seeds securely.

Get the coldkey address with 
```
btcli w list
```
and send funds to this address. They will be needed for registering the miner on the subnet.
To register the miner on the subnet, execute 
```
btcli subnet register --netuid 15 --subtensor.network finney --wallet.name miner --wallet.hotkey default
```

Exit Docker interactive mode. Restart the miner and indexer with 
```
docker-compose up -d
```

Wait for Memgraph to start; you can check the logs with 
```
docker-compose logs -f
```

Once Memgraph is ready, you can monitor the status of the miner.

Consider setting up firewall rules as your miner server's public IP is exposed. 
For UFW configuration, refer to [Configuring UFW](https://link_to_ufw_configuration_guide).

