




```
docker compose run memgraph up -d
docker compose run bitcoin-core up -d

docker compose run -e BITCOIN_END_BLOCK_HEIGHT=100 -e BITCOIN_START_BLOCK_HEIGHT=110 reverse-indexer

```