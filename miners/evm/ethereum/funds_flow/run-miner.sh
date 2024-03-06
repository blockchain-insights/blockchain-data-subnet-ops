#!/bin/bash

./version-script.sh

docker-compose -f docker-compose.miner.yml up -d