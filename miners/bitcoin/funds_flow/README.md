
# README for Bitcoin Funds Flow Miner and Indexer Setup

## Introduction
This guide provides instructions for setting up a Bitcoin funds flow miner and indexer using Docker, as part of a blockchain analysis platform. It involves configuring services defined in a `docker-compose.yml` file, with environment variables specified in a `.env` file.

## Prerequisites
- Docker and Docker Compose installed on your system.
- Basic knowledge of Docker, command-line operations, and blockchain technology.

## Installation Steps
1. **Clone the Repository**: Obtain the repository containing the `docker-compose.yml` and `.env.example` files.
2. **Configure Environment Variables**:
   - Copy `.env.example` to a new file named `.env`.
   - Edit `.env` to set the environment variables:
     - `VERSION`: Version of the services (default is unset).
     - `WALLET_NAME`: Name of your wallet (default is unset).
     - `WALLET_HOTKEY`: Hotkey for your wallet (default is unset).
     - `BLOCKCHAIR_API_KEY`: API key for Blockchair services (default is unset).
     - `GRAPH_DB_URL`: URL for the graph database service (default is unset).
     - `NODE_RPC_URL`: URL for the node's RPC interface (default is unset).
     - `WAIT_FOR_SYNC`: Flag to wait for synchronization (default is unset).
3. **Start the Services**:
   - Run `docker-compose up -d` in the directory with the `docker-compose.yml` file. This command starts the services in detached mode.
4. **Accessing the Services**:
   - The miner and indexer interact with blockchain data and a graph database.
   - `btcli` provides a CLI interface for additional operations.
   - `memgraph-funds-flow` runs the Memgraph database platform.
   - `dozzle` offers a web interface on port `9999` for log viewing.

## Running the Services
To start the services, navigate to the directory with `docker-compose.yml` and execute:
```bash
docker-compose up -d
```

## Stopping the Services
To stop all services, run:
```bash
docker-compose down
```

## Additional Notes
- The `bittensor` and `memgraph-funds-flow-data` volumes ensure data persistence.
- Customize the `.env` file to configure the setup according to your needs.
- Regular updates to Docker images are recommended for security and performance.
