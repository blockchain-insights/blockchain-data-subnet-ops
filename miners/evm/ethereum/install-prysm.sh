#!/bin/bash

curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh

./prysm.sh beacon-chain generate-auth-secret

chmod +x run-geth-memgraph.sh
chmod +x ./funds_flow/run-indexer.sh
chmod +x ./funds_flow/run-miner.sh
chmod +x ./funds_flow/run-multi-miner.sh
chmod +x ./funds_flow/run-subtensor.sh
chmod +x ./funds_flow/version-script.sh
