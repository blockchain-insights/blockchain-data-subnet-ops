1. Go to `miners/bitcoin-funds-flow` and create `.env` file.

    - `cd miners/bitcoin-funds-flow`
    - `cp .env.example .env`

2. Run bitcoin node.

    Ensure that you have `RPC_USER` and `RPC_PASSWORD` in `.env` file.

    Run `docker compose up -d bitcoin-core`

    Run `docker exec {container_id} bitcoin-cli -rpcuser={RPC_USER} -rpcpassword={RPC_PASSWORD} getblockcount` to see number of blocks indexed.

3. Run block parser to generate tx_out csv file.

    Run `docker compose run -e BITCOIN_START_BLOCK_HEIGHT={START_HEIGHT} -e BITCOIN_END_BLOCK_HEIGHT={END_HEIGHT} block-parser`

    You can find `tx_out-{START_HEIGHT}-{END_HEIGHT}.csv` generated in `bitcoin-vout-csv` volume. For example, you can go to `/var/lib/docker/volumes/bitcoin-vout-csv/_data` and run `ls` to see the generated files.

4. Run vout hashtable builder to generate pickle file from csv.
    
    Run `docker compose run -e CSV_FILE=/data_csv/tx_out-{START_HEIGHT}-{END_HEIGHT}.csv -e TARGET_PATH=/data_hashtable/{START_HEIGHT}-{END_HEIGHT}.pkl -e NEW=true bitcoin-vout-hashtable-builder`

    You can find `{START_HEIGHT}-{END_HEIGHT}.pkl` generated in `bitcoin-vout-hashtable` volume. For example, you can go to `/var/lib/docker/volumes/bitcoin-vout-hashtable/_data` and run `ls` to see the generated files.

5. Start memgraph server.

    - Ensure that you have `GRAPH_DB_USER` and `GRAPH_DB_PASSWORD` in `.env` file.

    - Ensure that you set up `vm.max_map_count` on your machine.

        - Edit the `/etc/sysctl.conf` file
            
            `sudo nano /etc/sysctl.conf`

        - Add the following line at the end of the file

            `vm.max_map_count=262444`

    - Run `docker compose up -d memgraph`

6. Run indexer.

    - Ensure that you have the following variables in `.env` file.

        - `BITCOIN_NODE_RPC_URL=http://${RPC_USER}:${RPC_PASSWORD}@bitcoin-core:8332`
        - `GRAPH_DB_URL=bolt://memgraph:7687`
        - `GRAPH_DB_USER={GRAPH_DB_USER}`
        - `GRAPH_DB_PASSWORD={GRAPH_DB_PASSWORD}`
        - `BITCOIN_INDEXER_START_BLOCK_HEIGHT={START_HEIGHT}`
        - `BITCOIN_INDEXER_END_BLOCK_HEIGHT={END_HEIGHT}`
        - `BITCOIN_INDEXER_IN_REVERSE_ORDER={REVERSE_ORDER (1 | 0)}`
        - `BITCOIN_V2_TX_OUT_HASHMAP_PICKLES=/data_hashtable/1-1000.pkl,/data_hashtable/1001-2000.pkl`

    - Note

        - `START_HEIGHT` is required and `END_HEIGHT` is optional.
        - `END_HEIGHT` must be equal or greater than `START_HEIGHT` if `REVERSE_ORDER` is 0.
        - `END_HEIGHT` must be equal or less than `START_HEIGHT` if `REVERSE_ORDER` is 1.
        - If `END_HEIGHT` is not set, indexer keeps indexing blocks in real-time, starting from `START_HEIGHT`.
        - You can specify multiple pickle files to `BITCOIN_V2_TX_OUT_HASHMAP_PICKLES` variable, splitting each pickle file name by comma. It loads those pickles files into memory and uses them for fast indexing.

    - Run `docker compose up -d indexer`

7. Check indexing status

    - Ensure that you have the following variables in `.env` file.

        - `GRAPH_DB_URL=bolt://memgraph:7687`
        - `GRAPH_DB_USER={GRAPH_DB_USER}`
        - `GRAPH_DB_PASSWORD={GRAPH_DB_PASSWORD}`

    - Run `docker compose run index-checker` to see which blocks are indexed in memgraph.
