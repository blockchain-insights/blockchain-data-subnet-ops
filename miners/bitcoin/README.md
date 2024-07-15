## Hardware Requirements
- All in one: 
  - ~8TB+ SSD/nvme storage, 32+ CPU cores, 1.5TB+ RAM
- Separate:
  - Indexer and MemGraph: 1.5TB+ RAM, 32+ CPU cores, ~7TB+ SSD/nvme storage
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
### Local Subtensor, Bitcoin node, Memgraph and Indexer
- **Running Local Subtensor (optional but recommended)**
    Start the subtensor:
    ```bash
    docker compose up -d node-subtensor
    ```

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

- **Running Postgres with TimescaleDB extension**

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    POSTGRES_USER=your_secret_user_name
    POSTGRES_PASSWORD=your_secret_password
    ```

    Start the Postgres
    ```
    docker compose up -d postgres
    ```

- **Running Funds Flow Indexer**

    Funds Flow Indexing is a slow process which can be accelerated by first generating pickle files for some of the blocks.
    For recent blocks, pickle files with at least 100000 size help with indexing speed.
    Below is an example procedure which does the following:
     - Generate pickle files for the recent blocks
     - Index them and start reverse indexing to block 1
     - When reverse indexing is done, you start forward indexing

    You can experiment with this process - the number of blocks, the reverse/forward indexing etc. Generating pickle files makes indexing faster, but takes a lot of memory, so keep an eye on the memory usage. Note, you need a local Bitcoin node running and synced.
    
    **1. Run block parser to generate tx_out csv file:**
    ```bash
    docker compose run --rm -e BLOCK_PARSER_START_HEIGHT=700000 -e BLOCK_PARSER_END_HEIGHT=830000 block-parser
    ```
    You can find `tx_out-{BLOCK_PARSER_START_HEIGHT}-{BLOCK_PARSER_END_HEIGHT}.csv` generated in `bitcoin-vout-csv` volume. For example, you can go to `/var/lib/docker/volumes/bitcoin-vout-csv/_data` and run `ls` to see the generated files.

    **2. Run vout hashtable builder to generate pickle file from csv:**
    ```bash
    docker compose run --rm -e CSV_FILE=/data_csv/tx_out-700000-830000.csv -e TARGET_PATH=/data_hashtable/700000-830000.pkl bitcoin-vout-hashtable-builder
    ```
    You can find `{BLOCK_PARSER_START_HEIGHT}-{BLOCK_PARSER_END_HEIGHT}.pkl` generated in `bitcoin-vout-hashtable` volume. For example, you can go to `/var/lib/docker/volumes/bitcoin-vout-hashtable/_data` and run `ls` to see the generated files.
    
    **3. Start reverse indexing:**

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    BITCOIN_INDEXER_IN_REVERSE_ORDER=1
    #In REVERSE ORDER, START_BLOCK should be greater than END_BLOCK
    BITCOIN_INDEXER_START_BLOCK_HEIGHT=830000
    BITCOIN_INDEXER_END_BLOCK_HEIGHT=1
    #You can specify multiple pickle files with full path separated by comma
    BITCOIN_V2_TX_OUT_HASHMAP_PICKLES=/data_hashtable/700000-830000.pkl
    ```

    Start the reverse indexer
    ```
    docker compose up -d funds-flow-indexer
    ```

    You can monitor the progress using the following command:
    ```
    docker compose run --rm funds-flow-index-checker
    ```

    **4. Start forward indexing:**

    When the reverse indexer is ready, stop it:

    ```
    docker compose down funds-flow-indexer
    ```

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    BITCOIN_INDEXER_IN_REVERSE_ORDER=0
    BITCOIN_INDEXER_START_BLOCK_HEIGHT=830000
    #SET END_BLOCK to -1 so that indexer keeps indexing blocks in real-time 
    BITCOIN_INDEXER_END_BLOCK_HEIGHT=-1
    ```

    Start the forward indexer
    ```
    docker compose up -d funds-flow-indexer
    ```

    You can monitor the progress using the following command:
    ```
    docker compose run --rm funds-flow-index-checker
    ```

    **5. Start smart indexing (run forward and reverse indexer simultaneously):**

    In smart mode, the indexer starts at START_HEIGHT and index forward to the latest block. If it reaches the latest block, it runs reverse indexing while waiting. If the new block is mined, it indexes the new block and runs reverse indexing again. If it finished reverse indexing, it just indexes latest blocks in real-time.

    When the indexer is ready, stop it:

    ```
    docker compose down funds-flow-indexer
    ```

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    BITCOIN_INDEXER_SMART_MODE=1
    BITCOIN_INDEXER_START_BLOCK_HEIGHT=830000
    #REVERSE_ORDER and END_BLOCK_HEIGHT are not required in smart mode
    #BITCOIN_INDEXER_IN_REVERSE_ORDER=0
    #BITCOIN_INDEXER_END_BLOCK_HEIGHT=-1
    ```

    Start the indexer again
    ```
    docker compose up -d funds-flow-indexer
    ```

    You can monitor the progress using the following command:
    ```
    docker compose run --rm funds-flow-index-checker
    ```

- **Running Balance Tracking Indexer**

    Balance Tracking Indexer also takes long and requires loading pickle files like Funds Flow Indexer.

    Start the indexer

    ```
    docker compose up -d balance-tracking-indexer
    ```

- **Running LLM Engine**

    Miners have to run a LLM engine container.

    Open the ```.env``` file:
    ```
    nano .env
    ```

    Set the required variables in the ```.env``` file and save it:
    ```ini
    CORCEL_API_KEY=your_corcel_api_key 
    NETWORK=bitcoin
    GRAPH_DB_URL=your_memgraph_db_url
    GRAPH_DB_USER=your_memgraph_user
    GRAPH_DB_PASSWORD=your_db_password
    ```

    Start the LLM engine container
    ```
    docker compose up -d llm-engine
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
    LLM_TYPE=openai # or corcel if you have a Corcel API Key
    ```

    **Optional ```.env``` variables with their defaults. Add them to your ```.env``` file ONLY if you are not satisfied with the defaults:**
    ```ini
    # If you want to use enternal Bitcoin node RPC.
    BITCOIN_NODE_RPC_URL=http://${RPC_USER}:${RPC_PASSWORD}@bitcoin-core:8332
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


