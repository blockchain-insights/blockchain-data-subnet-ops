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
  - [How to update container images](#how-to-update-container-images)

## Hardware Requirements
The services in this repository are tailored for machines with the following specifications:


### Miner

Each **miner** OR **validator** configuration requires to run bitcoin full node, which needs a server with **1TB+ SSD, 64GB+ RAM, 8 CPU cores**.
The full node can be installed on a separate machine or on the same machine as the miner and indexer. If you plan to run more than one miner, you can run a single full node for all miners.
In case of running on the same machine as the miner and indexer, the machine needs to have accordingly more resources **(  at least +1TB SSD )**

#### On-disk mode:
- Subnet Miner and Indexer: **1TB SSD, 256GB RAM, 8 CPU cores**

    ! Remember to set env variable in .env file !
    ```ini
    GRAPH_DB_STORAGE_MODE=ON_DISK_TRANSACTIONAL
    ```
_**Note**: Indexing and querying data in on-disk mode is extremely slower than running in in-memory mode._

#### In-memory mode:
- Subnet Miner and Indexer: **2TB SSD, 768GB-1TB RAM, +16 CPU cores**


### Validator
- Subnet Validator: **256GB SSD, 16GB RAM, 4 CPU cores**

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
    sudo apt-get install \
          apt-transport-https \
          ca-certificates \
          curl \
          gnupg \
          lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    sudo docker run hello-world

    sudo usermod -aG docker $USER
    newgrp docker
    docker --version
    ```
- [Docker Compose](https://docs.docker.com/compose/install/)
    ```
    sudo apt-get install docker-compose
    ```
 
## Pre-Installation
#### Configure Max Map Count
Configure max_map_count on machine running the Memgraph docker container (not inside!)

```
sudo nano /etc/sysctl.conf
```
add line ```vm.max_map_count = 2621440```

```
sudo sysctl -p
```

#### Clone the Repository

Clone the repository on each machine using: 

```
git clone https://github.com/blockchain-insights/blockchain-data-subnet-ops
```

The Docker base image for running the subnet miner, indexer, bittensor-cli, and validator is available in the [Registry](https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base). It will automatically download when you run \`docker-compose up -d\` for starting a specific service.

## Docker Compose Configuration
Create shared network for the services:
```
docker network create shared-network
```

### Bitcoin Node

The code resides in the ```miners/bitcoin``` directory of the cloned repository.
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
cp memgraph/create_user.txt.example memgraph/create_user.txt
```
edit file and set memgraph lab credentials
```
nano memgraph/create_user.txt
```

After tht execute:

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
VERSION=latest

# by convention, wallet name should be miner; and the hotkey should be default
# this setting can be skipped as its set in the docker-compose.indexer.yml file
WALLET_NAME=miner
WALLET_HOTKEY=default

# Point to the Bitcoin node RPC credentials
BITCOIN_NODE_RPC_URL=http://username:password@bitcoin-node:8332 

# this setting can be skipped as its set in the docker-compose.indexer.yml file
GRAPH_DB_URL=connection_string_to_memgraph_database

GRAPH_DB_USER=random_string
GRAPH_DB_PASSWORD=random_string

# use ON_DISK_TRANSACTIONAL on servers with less than 768GB RAM
GRAPH_DB_STORAGE_MODE=IN_MEMORY_TRANSACTIONAL|ON_DISK_TRANSACTIONAL

# The following variables are only required for the miner
# Miner waits for 95% sync with the Bitcoin node before starting
WAIT_FOR_SYNC=True

# The following variables are only required for the indexer, use defaults from docker compose
START_BLOCK_HEIGHT=769787
```

To start the miner and indexer, execute 
```
docker-compose up -d
```

Attach to the btcli container with 
```
docker container ls #get {container name} from results
docker-compose exec -it {container name} bash
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

#### Debug mode
In order to run miner in debug mode, execute 
```
docker-compose -f docker-compose.yml -f docker-compose.debug.yml up -d
```
This will expose port 9999 for docker log viewer and port 3000 for memgraph lab.
Keep in mind that this will expose those ports to the public internet, so use it only for debugging purposes.
It is worth protecting the miner with a firewall rule, check ```scripts/uwf.sh``` as an example.

**Be careful to do not deny ssh access to your server!**
 

#### Notes
for **GRAPH_DB_STORAGE_MODE = IN_MEMORY_TRANSACTIONAL** only

There is a possibility to restore the memgraph database from a snapshot ( starting block = 769787; ~current block = 818937 ). To do so, you need to:
- stop the memgraph container 
```
- docker container stop funds_flow_memgraph-funds-flow_1
```
- navigate to the memgraph docker volume directory 
```
-cd /var/lib/docker/volumes/funds_flow_memgraph-funds-flow-data/_data/
```
- remove content of the ```snapshots``` directory ```rm -rf snapshots/*```
- remove content of the ```wal``` directory ```rm -rf wal/*```
 
- navigate to the memgraph docker volume directory 
```
cd /var/lib/docker/volumes/funds_flow_memgraph-funds-flow-data/_data/snapshots
```
- curl the snapshot file from the server where it is stored 
```
curl -O https://blockchain-insights-snapshots.s3.fr-par.scw.cloud/bitcoin-funds-flow/20231129054952436318_timestamp_107073
```
- set file permissions ```chmod +rwx *```
- start the memgraph container again ```docker container start funds_flow_memgraph-funds-flow_1```






### Validator

The code is found in the ```validator``` directory of the cloned repository.
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
VERSION=latest

# by convention, wallet name should be validator; and the hotkey should be default
# this setting can be skipped as its set in the docker-compose.indexer.yml file
WALLET_NAME=validator
WALLET_HOTKEY=default

BITCOIN_NODE_RPC_URL=http://username:password@bitcoin-node:8332

# this setting can be skipped as its set in the docker-compose.indexer.yml file
BITCOIN_START_BLOCK_HEIGHT=769787
BITCOIN_CHEAT_FACTOR_SAMPLE_SIZE=256
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
#### Debug mode
In order to run validator in debug mode, execute 
```
docker-compose -f docker-compose.yml -f docker-compose.debug.yml up -d
```
This will expose port 9999 for docker log viewer and port 9998 for sqlite3 database viewer.
Keep in mind that this will expose the validator to the public internet, so use it only for debugging purposes.
It is worth protecting the validator with a firewall rule, check ```scripts/uwf.sh``` as an example.

**Be careful to do not deny ssh access to your server!**

## How to update container images
- check the latest base package version here:
```https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base```
- navigate to the directory where you cloned repository ```blockchain-data-subnet-ops``` repository
- execute ```git pull```
- execute ```docker pull ghcr.io/blockchain-insights/blockchain_insights_base:v0.1.29``` where ```v0.1.29``` is the latest version
- execute ```docker pull ghcr.io/blockchain-insights/blockchain_insights_base:latest``` we need this to overwrite the latest tag
- do custom changes to .env files if needed ( this will be announced at discord channel )
- navigate to miner or validator directory depending on which service you run
- execute ```docker-compose up -d``` to restart containers

