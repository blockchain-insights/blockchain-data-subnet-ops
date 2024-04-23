#!/bin/bash

# Function to determine which docker compose command to use
function get_docker_compose_cmd {
    if command -v docker-compose >/dev/null 2>&1; then
        echo "docker-compose"
    elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        echo "docker compose"
    else
        echo "Error: No compatible Docker Compose command found." >&2
        exit 1
    fi
}

# Get the appropriate Docker Compose command
DOCKER_COMPOSE_CMD=$(get_docker_compose_cmd)

# Loop indefinitely to monitor and restart the service as needed
while true; do
    # Start the Docker Compose service
    echo "Starting the services"
    $DOCKER_COMPOSE_CMD up -d --set validator.restart=never

    # Wait for the container to exit and get the exit code
    exit_code=$(docker wait validator)

    # Check the exit code and handle accordingly
    case "$exit_code" in
        0)
            echo "Container exited normally with code 0. Terminating the monitoring script."
            exit 0
            ;;
        3)
            echo "Container exited with code 3, pulling latest images..."
            $DOCKER_COMPOSE_CMD pull
            echo "Images pulled, restarting the service..."
            ;;
        *)
            echo "Container exited with code $exit_code, restarting the service..."
            ;;
    esac
done
