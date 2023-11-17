
# README for Bitcoin Node Installation

## Introduction
This guide provides instructions for setting up a Bitcoin node using Docker. The configuration is defined in a `docker-compose.yml` file and uses environment variables from a `.env` file for customization.

## Prerequisites
- Docker and Docker Compose installed on your system.
- Basic knowledge of Docker and command-line operations.

## Installation Steps
1. **Clone the Repository**: Clone or download the repository containing the `docker-compose.yml` and `.env.example` files.
2. **Configure Environment Variables**:
   - Copy the `.env.example` file to a new file named `.env`.
   - Edit the `.env` file to set the environment variables:
     - `RPC_USER`: Set a username for RPC access.
     - `RPC_PASSWORD`: Set a password for RPC access.
     - `RPC_ALLOW_IP`: Specify the IP address range allowed for RPC access (default is `0.0.0.0/0` for unrestricted access).
     - `RPC_BIND`: Set the address to bind for RPC access (default is `0.0.0.0`).
     - `VERSION`: Specify the version of the Bitcoin node (e.g., `22.0`). Leave blank for the latest version.
3. **Start the Bitcoin Node**:
   - Run the command `docker-compose up -d` in the directory containing the `docker-compose.yml` file. This will start the Bitcoin node in a detached mode.
4. **Accessing the Node**:
   - The Bitcoin node's JSON-RPC interface will be available at port `8332`.
   - Peer-to-peer connections are available at port `8333`.

## Running the Node
To start the Bitcoin node, navigate to the directory containing the `docker-compose.yml` file and run:
```bash
docker-compose up -d
```
This command will start the Bitcoin node in the background.

## Stopping the Node
To stop the node, run:
```bash
docker-compose down
```

## Additional Notes
- The `bitcoin-data` volume stores the blockchain and other Bitcoin data, ensuring data persistence across container restarts.
- Modify the `.env` file as needed to customize your node's configuration.
- Regularly update your Docker image to the latest version for security and performance improvements.
