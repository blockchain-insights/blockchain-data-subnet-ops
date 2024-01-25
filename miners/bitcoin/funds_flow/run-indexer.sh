#!/bin/bash

./version-script.sh

docker-compose -f docker-compose.indexer.yml up -d
