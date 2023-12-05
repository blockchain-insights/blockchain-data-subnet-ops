## Hardware Requirements

- All in one:
  - 1TB+ SSD, 16+ CPU cores, 128GB RAM
- Separate:
  - Validator: 8GB RAM, 4+ CPU cores, ~80GB+ SSD/nvme storage
  - Bitcoin full node: 1TB+ SSD/nvme storage, 8+ CPU cores, 96GB+ RAM


## System Configuration

### Setup
- Clone the Repository
    ```
    git clone https://github.com/blockchain-insights/blockchain-data-subnet-ops
    ```

    The Docker base image for running the validator and bittensor-cli is available in the [Registry](https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base). It will be automatically downloaded when you run services with **docker-compose** .

#### Validator and Bitcoin Node

- **Running Bitcoin node**
  
  Navigate to ```miners/bitcoin``` and run the following commands:
  ```
  cp .env.example .env
  nano .env
  ```
  Setup mandatory variables in ```.env``` file.
  ```ini
  RPC_USER=your_secret_user_name
  RPC_PASSWORD=your_secret_password
  ```
  To increase the node security you can also setup the following variables:
  ```init
    RPC_ALLOW_IP=Ip address of your miner server
    RPC_BIND=network interface to bind to
  ```
    To run the node execute the following command:
    ```
    docker-compose up -d
    ```

- **Running Validator**
  - **Configure Validator**
  
      Navigate to ```validator``` and run the following commands:

  - **Setup variables in .env file.**
    ```ini
    BITCOIN_NODE_RPC_URL=http://username:password@bitcoin-node:8332
    ```
    There are also optional variables that can be set:
    ```ini
    WALLET_NAME=validator
    WALLET_HOTKEY=default
    BITTENSOR_VOLUME_PATH=~/.bittensor
    ```
  - **Start Validator**
    ```
    docker-compose -f docker-compose.yml up -d
    ```
    Note: you can start dozzle docker log viewer by running 
    ```
    docker-compose -f docker-compose.yml -f docker-compose.debug.yml up -d
    ```
    
- **Configure Validator Hotkey**
  
  If you don't already have validator keys configured in the default bittensor directory, or in the overridden $BITTENSOR_VOLUME_PATH set in .env, then you can create one using the ready docker with the below commands 
  ```
  docker-compose -f docker-compose.yml -up -d
  docker exec -it validator_btcli_1 bash
  btcli wallet new_coldkey --wallet.name validator
  btcli wallet new_hotkey --wallet.name validator --wallet.hotkey default
  ```
### Monitoring

To monitor your containers, ensure that you run debug compose files (```docker-compose.debug.yml```), and then navigate to ```http://your_server_ip:9999```

### Upgrading

- check the latest base package version here:
```https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base```
- navigate to the directory where you cloned repository ```blockchain-data-subnet-ops``` repository
- execute ```git pull```
- execute ```docker pull ghcr.io/blockchain-insights/blockchain_insights_base:v0.xx.xx``` where ```v0.xx.xx``` is the latest version
- execute ```docker pull ghcr.io/blockchain-insights/blockchain_insights_base:latest``` we need this to overwrite the latest tag
- do custom changes to .env files if needed ( this will be announced at discord channel )
- navigate to docker compose files directory depending on which service you run and start docker compose again
