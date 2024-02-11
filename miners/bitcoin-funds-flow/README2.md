




```

docker compose run bitcoin-core up -d

docker compose run -e BITCOIN_END_BLOCK_HEIGHT=137000 -e BITCOIN_START_BLOCK_HEIGHT=1 block-parser

docker compose run -e CSV_FILE=/data_csv/tx_in-1-1000.csv -e TARGET_PATH=/data_hashtable/1-1000.pkl bitcoin-vout-hashtable-builder

docker compose run memgraph up -d 

docker compose run -e BITCOIN_END_BLOCK_HEIGHT=100 -e BITCOIN_START_BLOCK_HEIGHT=110 reverse-indexer

```