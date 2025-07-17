#!/bin/bash

echo "Deploying Traefik + Authelia + Dashy stack..."

# Create external network if it doesn't exist
docker network create --driver overlay traefik 2>/dev/null || true

# Generate secrets if they don't exist
if ! docker secret ls | grep -q authelia_jwt_secret; then
    echo "Generating secrets..."
    ./scripts/generate-secrets.sh
fi

# Deploy the stack
docker stack deploy -c docker-compose.yml traefik-stack

echo "Stack deployed! Checking status..."
docker stack ps traefik-stack
