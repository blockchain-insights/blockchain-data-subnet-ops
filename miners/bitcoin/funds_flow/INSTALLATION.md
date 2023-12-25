## Hardware Requirements
- All in one: 
  - 2TB+ SSD/nvme storage, 16+ CPU cores, 1TB RAM
- Separate:
  - Indexer and MemGraph: 768GB-1TB+ RAM, 16+ CPU cores, ~2TB+ SSD/nvme storage
  - Bitcoin full node: 1TB+ SSD/nvme storage, 8+ CPU cores, 64GB+ RAM
  - Miner: ~32GB SSD storage, 8+ CPU cores, 64GB+ RAM
- Custom:
  - Find your own best configuration ;)

## System Configuration

### Setup
- Clone the Repository
    ```
    git clone https://github.com/blockchain-insights/blockchain-data-subnet-ops
    ```

    The Docker base image for running the miner, indexer and bittensor-cli is available in the [Registry](https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base). It will be automatically downloaded when you run services with **docker-compose** .

#### Indexer and Databases

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

- **Running Indexer and MemGraph**

  - **Configure Max Map Count**

    Configure max_map_count on machine running the Memgraph docker container (not inside!)
  
    ```
    sudo nano /etc/sysctl.conf
    ```

    add line

    ```
    vm.max_map_count = 8621440
    ```
    save changes and run
    ```
    sudo sysctl -p
    ```

  - **Configure Memgraph & Indexer**
  
    Navigate to ```miners/bitcoin/funds_flow``` and run the following commands:
  
    ```
    cp memgraph/create_user.txt.example memgraph/create_user.txt
    ```
    edit file and set memgraph lab credentials
    ```
    nano memgraph/create_user.txt
    ```
  - **Setup variables in .env file.**
  
    _(you can copy reference variables by executing ```cp .env.example .env```)_
    ```ini
    GRAPH_DB_USER=your_secret_user_name
    GRAPH_DB_PASSWORD=your_secret_password
    BITCOIN_NODE_RPC_URL=http://username:password@bitcoin-node:8332
    ```
    There are also optional variables that can be set:
    ```ini
    # use ON_DISK_TRANSACTIONAL on servers with less than 768GB RAM, but indexing can take 1 month instead of few days
    GRAPH_DB_STORAGE_MODE=IN_MEMORY_TRANSACTIONAL|ON_DISK_TRANSACTIONAL
    GRAPH_DB_URL=connection_string_to_memgraph_database
    BLOCK_PROCESSING_TRANSACTION_THRESHOLD=1000
    BLOCK_PROCESSING_DELAY=1
    BITCOIN_START_BLOCK_HEIGHT=769787
    BITTENSOR_VOLUME_PATH=~/.bittensor
    ```
  - **Start Indexer & Memgraph**
    ```
    docker-compose -f docker-compose.indexer.yml up -d
    ```
    Note: you can expose memgraph lab ui and dozzle docker log viewer by running 
    ```
    docker-compose -f docker-compose.indexer.yml -f docker-compose.debug.yml up -d
    ```

#### Miner
**Note**: It's beneficial to register the miner hotkey when the indexer is up to date; otherwise, the miner will have to wait for the indexer to sync. Additionally, if the miner is not operational for an extended period, there's a risk of the hotkey being deregistered.
This can be omitted by setting ```WAIT_FOR_SYNC=False``` in ```.env``` file, but be aware that this might impact the miner's rewards.
- **Configure Miner Hotkey**

  If you don't already have validator keys configured in the default bittensor directory, or in the overridden $BITTENSOR_VOLUME_PATH set in .env, then you can create one using the ready docker with the below commands
  ```
  docker-compose -f docker-compose.miner.yml -up -d
  docker exec -it funds_flow_btcli_1 bash
  btcli wallet new_coldkey --wallet.name miner
  btcli wallet new_hotkey --wallet.name miner --wallet.hotkey default
  ```
- **Configure Miner**

  Run 
  Navigate to ```miners/bitcoin/funds_flow``` and edit existing ```.env``` file or create new one:

  ```ini
  GRAPH_DB_USER=your_secret_user_name
  GRAPH_DB_PASSWORD=your_secret_password
  BITCOIN_NODE_RPC_URL=http://username:password@bitcoin-node:8332
  
  ```
  There are also optional variables that can be set:
  ```ini
  WALLET_NAME=miner
  WALLET_HOTKEY=default
  GRAPH_DB_URL=connection_string_to_memgraph_database
  WAIT_FOR_SYNC=True
  ```
- **Start Miner**
  ```
  docker-compose -f docker-compose.miner.yml up -d
  ```
  Note: you can expose dozzle docker log viewer by running 
  ```
  docker-compose -f docker-compose.miner.yml -f docker-compose.debug.yml up -d
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
