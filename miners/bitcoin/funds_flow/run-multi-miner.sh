#!/bin/bash

./version-script.sh

docker-compose -f docker-compose.multi-miner.yml up -d
