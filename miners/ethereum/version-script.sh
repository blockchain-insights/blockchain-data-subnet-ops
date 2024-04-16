#!/bin/bash

DOCKER_IMAGE="ghcr.io/blockchain-insights/blockchain_insights_base"

# Check if the Docker image is present locally
if ! docker image inspect "$DOCKER_IMAGE" > /dev/null 2>&1; then
    echo "Image not found locally. Pulling $DOCKER_IMAGE..."
    docker pull "$DOCKER_IMAGE"
else
    echo "$DOCKER_IMAGE found locally; saving version info."
fi

DIGEST=$(docker image inspect --format='{{index .RepoDigests 0}}' "ghcr.io/blockchain-insights/blockchain_insights_base")

SHA256_DIGEST=$(echo "$DIGEST" | cut -d "@" -f2)
DIGEST_CHARS=${SHA256_DIGEST:7:4}${SHA256_DIGEST: -4}

# Path to the .env file
ENV_FILE=".env"

# Check if .env file exists
if [ -f "$ENV_FILE" ]; then
    # Check if DIGEST_CHARS variable exists in the file
    if grep -q "DIGEST_CHARS=" "$ENV_FILE"; then
        # Replace the existing DIGEST_CHARS value
        sed -i "s/^DIGEST_CHARS=.*/DIGEST_CHARS=$DIGEST_CHARS/" "$ENV_FILE"
    else
        # Add DIGEST_CHARS variable to the file
        echo "DIGEST_CHARS=$DIGEST_CHARS" >> "$ENV_FILE"
    fi
else
    # Create .env file and add DIGEST_CHARS variable
    echo "DIGEST_CHARS=$DIGEST_CHARS" > "$ENV_FILE"
fi