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
# this setting can be skipped as its set in the docker-compose.yml file
WALLET_NAME=miner
WALLET_HOTKEY=default

# Point to the Bitcoin node RPC credentials
BITCOIN_NODE_RPC_URL=http://username:password@bitcoin-node:8332 

# this setting can be skipped as its set in the docker-compose.yml file
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

Once Memgraph is ready, you can monitor the status of your containers via web browser, just navigate to 
```
http://{your machine ipaddress}:9999
```

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
# this setting can be skipped as its set in the docker-compose.yml file
WALLET_NAME=validator
WALLET_HOTKEY=default

BITCOIN_NODE_RPC_URL=http://username:password@bitcoin-node:8332

# this setting can be skipped as its set in the docker-compose.yml file
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

