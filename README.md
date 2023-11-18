
# Blockchain Data Subnet Operations

Welcome to the Blockchain Data Subnet Operations repository! This repository contains Docker configurations and scripts for running various blockchain analysis tools and nodes. Each service in this repository is part of a larger effort to provide insights into blockchain data and operations.

## Hardware Requirements
The services in this repository are designed to run on a machine with the following specifications:
- Bitcoin full node: 1TB SSD, 64GB RAM, 8 CPU cores
- Subnet Miner and Indexer: 1TB SSD, 256GB RAM, 16 CPU cores
- Subnet Validator: 256GB SSD, 16GB RAM, 4 CPU cores

Recommended provider: [Scaleway](https://www.scaleway.com/) ( Bare Metal Servers )

## Prerequisites
Foreach server you will need to install the following:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Python 3](https://www.python.org/downloads/)

## Pre-Installation

On each machine clone this repo ``git clone https://github.com/blockchain-insights/blockchain-data-subnet-ops``

Docker base image for running the subnet miner, indexer, bittensor-cli, validator is located in [Registry](https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base)
and it will be automatically downloaded when you run docker-compose up -d when starting particular service.

## Docker compose configuration

### Bitcoin Node

Code is located in ```miners\bitcoin-node``` directory of the cloned repository.
Execute cd into the directory and execute ```cp .env.example .env``` 
and edit file with ```nano .env``` to set the following variables:

#### Variables
- RPC_USER=set_this_to_a_random_string
- RPC_PASSWORD=set_this_to_a_random_string
- RPC_ALLOW_IP=this should point to the ip address of your subnet miner server
- RPC_BIND=this should point to the network interface used for communiaction with the subnet miner server
- VERSION=latest

To start the bitcoin node execute ```docker-compose up -d```
Synchorization of the blockchain will take a while. You can check the progress by executing ```docker-compose logs -f```

### Subnet Miner and Indexer

Code is located in ```miners\funds_flow``` directory of the cloned repository.
Execute cd into the directory and execute ```cp .env.example .env``` 
and edit file with ```nano .env``` to set the following variables:

#### Variables
VERSION=v0.1.1  # version of the miner and indexer 
WALLET_NAME=miner|validator
WALLET_HOTKEY=default
BLOCKCHAIR_API_KEY=you have to obtain api key from [Blockchair](https://blockchair.com/), if you are a validator use the key allowing the most requests; miners can use the cheapest key
NODE_RPC_URL=http://username:password@bitcoin-node:8332 # this should point to the bitcoin node and rpc credentials
GRAPH_DB_URL=connection to  memgraph database, can be skipped
GRAPH_DB_USER=set this to a random string
GRAPH_DB_PASSWORD=set this to a random string
WAIT_FOR_SYNC=by default its set to True, its being used for miner to wait for 95% sync with the bitcoin node before starting the miner

To start the miner and indexer execute ```docker-compose up -d```
Attach to btcli container ```docker-compose exec btcli bash``` and to create subnet cold key and hotkey by executing commands
btcli w create_coldkey and set 'miner' as wallet name; store your wallet password in a safe place
then create a hotkey named default for the miner wallet by executing btcli w create_hotkey
check the wallet by executing btcli w list
deposit somefunds to the wallet address (coldkey) and register your hotkey for the subnet by executing
btcli subnet recycle_register --netuid 15 --subtensor.network finney --wallet.name miner --wallet.hotkey default
exit docker interactive

now run docker-compose down and docker-compose up -d to restart the miner and indexer
wait a bit for memgraph to start, you can check the logs by executing docker-compose logs -f
when memgraph is ready you can check the status of the miner by executing

or access your server public address on port 9999 from the browser to check the docker logs via dozzle log viewer

consider setting up a firewall rules as your public ip of the miner server is publicly know
setup some ufw rules (put link to configuring ufw)
 