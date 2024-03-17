## Hardware Requirements
- All in one:
  - 2TB+ SSD/nvme storage, 16+ CPU cores, 2TB RAM
- Separate:
  - Indexer and MemGraph: 768GB-1TB+ RAM, 16+ CPU cores, ~1TB+ SSD/nvme storage
  - Ethereum full node: 1TB+ SSD/nvme storage, 8+ CPU cores, 64GB+ RAM
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
- Navigate to ```blockchain-data-subnet-ops/miners/ethereum-funds-flow``` and copy the example ```.env``` file:
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

### Local Subtensor, Ethereum node, Memgraph and Indexer
- **Running Local Subtensor (optional but recommended)**
    Start the subtensor:
    ```bash
    docker compose up -d node-subtensor
    ```

- **Running Ethereum Archive Node & Consensus Client**

  Make sure you are in `blockchain-data-subnet-ops/miners/ethereum-funds-flow` and run the following command to generate `jwt.hex` file:

  ```bash
  curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh && ./prysm.sh beacon-chain generate-auth-secret
  ```

  To run `ethereum archive node` and `prysm` with the generated `jwt.hex` file, execute the following command:

  ```bash
  docker-compose up -d ethereum-node prysm
  ```

  Prior to running indexer, please make sure `Ethereum archive node` syncing is done. You can check it with the following commands:

  ```bash
  docker ps
  docker exec -it <docker_container_id> geth attach
  eth.syncing
  eth.blockNumber
  ```

  Wait till `eth.syncing` returns FALSE and `eth.blockNumber` returns current valid block Height.

- **Running Memgraph**

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    GRAPH_DB_USER=your_secret_user_name
    GRAPH_DB_PASSWORD=your_secret_password
    ```

    Start the Memgraph
    ```
    docker compose up -d memgraph
    ```

- **Running Indexer**

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    ETHEREUM_SUB_START_BLOCK_HEIGHT=1
    ETHEREUM_SUB_END_BLOCK_HEIGHT=19374685
    ETHEREUM_SUB_THREAD_CNT=20
    ```

    **Optional ```.env``` variables with their defaults. Add them to your ```.env``` file ONLY if you are not satisfied with the defaults:**
    ```ini
    BLOCK_PROCESSING_TRANSACTION_THRESHOLD=1000
    BLOCK_PROCESSING_DELAY=1
    # If you want to use enternal Ethereum node RPC.
    ETHEREUM_NODE_RPC_URL=http://127.0.0.1:8545
    ```

    Start the Indexer
    ```
    docker compose up -d indexer
    ```

### Miner
**NOTE**: It's beneficial to register and run your miner hotkey ***only when*** the indexer is up to date with recent blocks, otherwise, the miner will receive low score. Additionally, if the miner is not operational for an extended period, there's a risk of the hotkey being deregistered.

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
    # If you want to use enternal Ethereum node RPC.
    ETHEREUM_NODE_RPC_URL=http://127.0.0.1:8545
    # If you want to use external Memgraph instance.
    GRAPH_DB_URL=bolt://memgraph:7687
    # Set to True if you want your miner to work only when the Indexer is 100% in sync, but be aware that this might impact the miner's rewards.
    WAIT_FOR_SYNC=False
    # If you have custom bittensor path
    BITTENSOR_VOLUME_PATH=~/.bittensor
    # By default miners use local subtensor node, but you can specify a different one
    SUBTENSOR_NETWORK=local
    SUBTENSOR_URL=ws://IP:PORT
    ```

    **Run the version-script.sh before starting the miner**
    ```bash
    ./version-script.sh
    ```

    Start the Miner
    ```
    docker compose up -d miner1
    ```

#### Multiple miners
It's allowed to run a total of 9 miners on a single memgraph instance. You have to first create and register the hotkeys, the procedure is similar to the one for the default miner.

- **Running Multiple Miners**
    While creating bittensor wallet hotkeys, keep the following conventio: default1 ... default9
    
    **NOTE**: It is not required to add all 9 miners, you can add less too.

    Start the additional miners
    ```
    docker compose up -d miner2 miner3 ... miner9
    ```
    If you want to start them all, you can use the command:
    ```
    docker compose --profile multiminers up -d
    ```

### Monitoring

To easily monitor your containers, you can start Dozzle:
```bash
docker run -d --name dozzle --restart unless-stopped --volume=/var/run/docker.sock:/var/run/docker.sock --volume /root/dozzle:/data -p 9999:8080 amir20/dozzle:latest --auth-provider simple
```

Then navigate to `/dozzle` directory and generate your password sha256 `echo -n 'secret-password' | sha256sum`
In next step execute `nano users.yml` and paste following content:

```
users:
  # "admin" here is username
  admin:
    name: "admin"
    # Just sha-256 which can be computed with "echo -n password | shasum -a 256"
    password: "YOUR_HASH_GOES_HERE"
    email: some@email.net
```

At the end, restart the container by executing `docker container restart dozzle`

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
- check the ```VERSION``` variable in your ```.env``` file and update it to match the new version if needed
- **run the version-script.sh before restarting the miner**
    ```bash
    ./version-script.sh
    ```
- restart containers
    ```bash
    docker compose up -d indexer miner1
    ```
- if needed restart other containers too
- when additional changes are needed, they will be announced on Discord