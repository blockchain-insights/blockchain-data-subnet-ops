## Hardware Requirements
- All in one: 
  - 2TB+ SSD/nvme storage, 16+ CPU cores, 1.5TB+ RAM
- Separate:
  - Indexer and MemGraph: 1.5TB+ RAM, 16+ CPU cores, ~2TB+ SSD/nvme storage
  - Bitcoin full node: 1TB+ SSD/nvme storage, 8+ CPU cores, 64GB+ RAM
  - Miner: ~32GB SSD storage, 8+ CPU cores, 64GB+ RAM
- Custom:
  - Find your own best configuration ;)

## System Configuration

```diff
- Most users need only what is explained in this documentation. Editing the docker-compose files and the optional variables may create problems and is for advanced users only!
```

### Setup

- Clone this repository:
    ```bash
    git clone https://github.com/blockchain-insights/blockchain-data-subnet-ops
    ```
- Navigate to ```blockchain-data-subnet-ops/miners/bitcoin-funds-flow``` and copy the example ```.env``` file:
    ```bash
    cp .env.example .env
    ```
- Configure Max Map Count:
    ```bash
    # For 1TB RAM
    echo "vm.max_map_count=8388608" | sudo tee -a /etc/sysctl.conf
    
    # For 1.5TB RAM
    echo "vm.max_map_count=12582912" | sudo tee -a /etc/sysctl.conf
    
    # For 2TB RAM
    echo "vm.max_map_count=16777216" | sudo tee -a /etc/sysctl.conf
    
    # For 2.5TB RAM
    echo "vm.max_map_count=20971520" | sudo tee -a /etc/sysctl.conf
    
    # For 3TB RAM
    echo "vm.max_map_count=25165824" | sudo tee -a /etc/sysctl.conf
    
    # For 3.5TB RAM
    echo "vm.max_map_count=29360128" | sudo tee -a /etc/sysctl.conf
    
    # For 4TB RAM
    echo "vm.max_map_count=33554432" | sudo tee -a /etc/sysctl.conf

    sudo sysctl -p
    ```
#### Bitcoin node, Memgraph and Indexer

- **Running Bitcoin node**

    Open the ```.env``` file:
    ```bash
    nano .env
    ```
    Set the required variables in the ```.env``` file and save it:
    ```ini
    RPC_USER=your_secret_user_name
    RPC_PASSWORD=your_secret_password
    ```
    
    **Optional ```.env``` variables with their defaults. Add them to your ```.env``` file ONLY if you are not satisfied with the defaults:**
    ```ini
    RPC_ALLOW_IP=172.16.0.0/12
    RPC_BIND=0.0.0.0
    MAX_CONNECTIONS=512
    ```

    Start the Bitcoin node:
    ```bash
    docker compose up -d bitcoin-core
    ```

- **Running Indexer and Memgraph**

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    GRAPH_DB_USER=your_secret_user_name
    GRAPH_DB_PASSWORD=your_secret_password
    ```

    **Optional ```.env``` variables with their defaults. Add them to your ```.env``` file ONLY if you are not satisfied with the defaults:**
    ```ini
    # If you want to use enternal Bitcoin node RPC.
    BITCOIN_NODE_RPC_URL=http://${RPC_USER}:${RPC_PASSWORD}@bitcoin-core:8332
    # If you want to use external Memgraph instance.
    GRAPH_DB_URL=bolt://memgraph:7687
    # From which block to start initial indexing. More blocks require more initial time but give better rewards. At least 50000 indexed blocks are preferable.
    BITCOIN_START_BLOCK_HEIGHT=769787
    ```

    Start the Indexer & Memgraph
    ```
    docker compose up -d memgraph indexer
    ```

#### Miner and IP blocker
**NOTE**: It's beneficial to register and run your miner hotkey ***only when*** the indexer is up to date, otherwise, the miner will have to wait for the indexer to sync. Additionally, if the miner is not operational for an extended period, there's a risk of the hotkey being deregistered.

- **Register Miner Hotkey**

    If you have not already registered your hotkey on subnet 15, run the following command:
    ```bash
    btcli s register --subtensor.network finney --netuid 15
    ```

- **Running Miner**

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    WALLET_NAME=default
    WALLET_HOTKEY=default
    ```

    **Optional ```.env``` variables with their defaults. Add them to your ```.env``` file ONLY if you are not satisfied with the defaults:**
    ```ini
    # If you want to use enternal Bitcoin node RPC.
    BITCOIN_NODE_RPC_URL=http://${RPC_USER}:${RPC_PASSWORD}@bitcoin-core:8332
    # If you want to use external Memgraph instance.
    GRAPH_DB_URL=bolt://memgraph:7687
    # Set to False if you want your miner to work without waiting for the Indexer to sync, but be aware that this might impact the miner's rewards.
    WAIT_FOR_SYNC=True
    # If you have custom bittensor path
    BITTENSOR_VOLUME_PATH=~/.bittensor
    # By default miners use the public SN15 subtensor, but you can use other too
    SUBTENSOR_NETWORK=local
    SUBTENSOR_URL=ws://51.158.60.18:9944
    ```

    **Run the version-script.sh before starting the miner**
    ```bash
    ./version-script.sh
    ```

    Start the Miner & IP blocker
    ```
    docker compose up -d miner ip-blocker
    ```

#### Multiple miners
It's allowed to run a total of 9 miners on a single memgraph instance. You have to first create and register the hotkeys, the procedure is similar to the one for the default miner.

- **Running Multiple Miners**
    While creating bittensor wallet hotkeys, keep the following conventio: default1 ... default6
    
    **NOTE**: It is not required to add all 6 miners, you can add less too.

    Start the additional miners
    ```
    docker compose up -d miner1 miner3 ... miner6
    ```
    If you want to start them all, you can use the command:
    ```
    docker compose --profile multiminers up -d
    ```

### Monitoring

To easily monitor your containers, you can start Dozzle:
```bash
docker run -d --name dozzle --restart unless-stopped --volume=/var/run/docker.sock:/var/run/docker.sock -p 9999:8080 amir20/dozzle:latest
```
Then navigate to ```http://your_server_ip:9999```

### Upgrading

- check the latest base package version [here](https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base)
- update the repository
    ```bash 
    git pull
    ```
- update the images
    ```bash
    docker compose pull
    ```
- **run the version-script.sh before restarting the miner**
    ```bash
    ./version-script.sh
    ```
- restart containers
    ```bash
    docker compose up -d indexer miner ip-blocker
    ```
- if needed restart other containers too
- when additional changes are needed, they will be announced on Discord
