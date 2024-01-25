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
VERSION=${SHA256_DIGEST:7:4}${SHA256_DIGEST: -4}
echo "Version: $VERSION"

# Path to the .env file
ENV_FILE=".env"

# Check if .env file exists
if [ -f "$ENV_FILE" ]; then
    # Check if VERSION variable exists in the file
    if grep -q "VERSION=" "$ENV_FILE"; then
        # Replace the existing VERSION value
        sed -i "s/^VERSION=.*/VERSION=$VERSION/" "$ENV_FILE"
    else
        # Add VERSION variable to the file
        echo "VERSION=$VERSION" >> "$ENV_FILE"
    fi
else
    # Create .env file and add VERSION variable
    echo "VERSION=$VERSION" > "$ENV_FILE"
fi
