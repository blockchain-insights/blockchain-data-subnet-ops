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
    - [Miner and Indexer](#miner-and-indexer)
    - [Subnet Validator](#validator)

## Hardware Requirements
The services in this repository are tailored for machines with the following specifications:


### Miner

Each miner configuration requires to run bitcoin full node, which needs **1TB+ SSD, 64GB+ RAM, 8 CPU cores**.
The full node can be installed on a separate machine or on the same machine as the miner and indexer.
In case of running on the same machine as the miner and indexer, the machine needs to have accordingly more resources **(  at least +1TB SSD )**

#### On-disk mode:
- Subnet Miner and Indexer: **1TB SSD, 256GB RAM, 8 CPU cores**

    ! Remember to set env variable in .env file !
    ```ini
    GRAPH_DB_STORAGE_MODE=ON_DISK_TRANSACTIONAL
    ```

#### In-memory mode:
- Subnet Miner and Indexer: **2TB SSD, 768GB-1TB RAM, +16 CPU cores**

The corrected text would be: 

_**Note**: Indexing and querying data in on-disk mode is much slower than running in in-memory mode._


### Validator
- Subnet Validator: 256GB SSD, 16GB RAM, 4 CPU cores

### Server hosting
- https://contabo.com/en/dedicated-servers/
- https://www.hetzner.com/dedicated-rootserver/matrix-ax
- https://www.scaleway.com/

## Prerequisites
Update the package manager:
```
sudo apt update
``` 

For each server, you'll need to install:
- [Docker](https://docs.docker.com/get-docker/)
    ```
    sudo apt-get install docker
    ```
- [Docker Compose](https://docs.docker.com/compose/install/)
    ```
    sudo apt-get install docker-compose
    ```
- [Python 3](https://www.python.org/downloads/)
    ```
    sudo apt update
    sudo apt install python3 python3-pip
    echo "alias python=python3" >> ~/.bashrc
    source ~/.bashrc
    python --version
    ```
- [Blockchair](https://blockchair.com/) API Key (cheap for miners, expensive for validators)
 
## Pre-Installation
#### Configure Max Map Count
Configure max_map_count on machine running the Memgraph docker container (not inside!)

```
sudo nano /etc/sysctl.conf
```
add line ```vm.max_map_count = 862144```

```
sudo sysctl -p
```
#### Configure Docker Memory Limit

The default memory limit for Docker is 2GB. This is not enough for running the Memgraph database.
You can increase the memory limit by following the steps below.
Edit the Docker daemon configuration file:

```
sudo nano /lib/systemd/system/docker.service
```
In section **[Service]** add the following line:
```
MemoryLimit=255G
```
Reload the daemon and restart the Docker service:
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```
Verify the changes:
```
docker info | grep -i memory
```
#### Configure Docker Swap Memory

By default, Docker does not use swap memory. This can cause issues when running the Memgraph database.
You can enable swap memory by following the steps below.
Edit the Docker daemon configuration file:

```
sudo nano /lib/systemd/system/docker.service
```
Locate the line starting with **ExecStart=**. This line defines the command used to start the Docker daemon. Add the following option to the end of the line:

```
--memory-swap=-1
```
Example:
```
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --memory-swap=-1
```

Reload the daemon and restart the Docker service:
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```
 
#### Clone the Repository

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

### Miner and Indexer

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

# use ON_DISK_TRANSACTIONAL on servers with less than 768GB RAM
GRAPH_DB_STORAGE_MODE=IN_MEMORY_TRANSACTIONAL|ON_DISK_TRANSACTIONAL
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
docker-compose down
docker-compose up -d
```

Wait for Memgraph to start; you can check the logs with 
```
docker-compose logs -f
```

Once Memgraph is ready, you can monitor the status of the miner.

### Validator

The code is found in the ```validators``` directory of the cloned repository.
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
```

To start the validator, execute 
```
docker-compose up -d
```

Attach to the btcli container with 
```
docker-compose exec btcli bash
```
and create a cold and hot keys for the validator wallet with 
```
btcli wallet new_coldkey --wallet.name validator
btcli wallet new_hotkey --wallet.name validator --wallet.hotkey default
```

Remember to store the wallet seeds securely.

Get the coldkey address with 
```
btcli w list
```
and send funds to this address. They will be needed for registering the validator on the subnet.

To register the validator on the subnet, execute 
```
btcli subnet register --netuid 15 --subtensor.network finney --wallet.name validator --wallet.hotkey default
```

Exit Docker interactive mode. Restart the validator with 
```
docker-compose down
docker-compose up -d
```

