
# README for Bittensor Validator and CLI Setup

## Introduction
This guide outlines the setup for a Bittensor validator and `btcli`, a CLI tool for Bittensor, using Docker. The setup is defined in a `docker-compose.yml` file, utilizing environment variables from a `.env` file.

## Prerequisites
- Docker and Docker Compose installed on your system.
- Familiarity with Docker, command-line operations, and Bittensor network basics.

## Installation Steps
1. **Clone the Repository**: Obtain the repository containing the `docker-compose.yml` and `.env.example` files.
2. **Configure Environment Variables**:
   - Copy `.env.example` to a new file named `.env`.
   - Edit `.env` to set the environment variables:
     - `VERSION`: Bittensor version (default is `latest`).
     - `WALLET_NAME`: Name of your Bittensor wallet.
     - `WALLET_HOTKEY`: Hotkey for your wallet.
     - `BLOCKCHAIR_API_KEY`: Your Blockchair API key.
3. **Start the Services**:
   - Run `docker-compose up -d` in the directory with `docker-compose.yml`. This command starts the services in detached mode.
4. **Accessing the Services**:
   - `btcli` provides the Bittensor CLI interface for wallet management and key operations.
   - `validator` participates in the Bittensor network, validating miner output.
   - `dozzle` offers a web interface on port `9999` for viewing container logs.

## Running the Services
To start the Bittensor services, navigate to the directory with `docker-compose.yml` and execute:
```bash
docker-compose up -d
```

## Stopping the Services
To stop all services, run:
```bash
docker-compose down
```

## Additional Notes
- The `bittensor` volume is crucial for persisting network data and configurations.
- Customize your `.env` file to fine-tune the validator and CLI settings.
- Regularly update your Docker images to ensure security and performance.
