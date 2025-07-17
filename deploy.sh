#!/bin/bash

echo "Deploying Traefik + Authelia + Dashy with Rootless Docker..."

# Detect Docker socket
source scripts/detect-docker-socket.sh

# Update docker-compose.yml with correct socket path
if [ -n "$DOCKER_SOCK" ]; then
    echo "Using Docker socket: $DOCKER_SOCK"
    # Create temporary docker-compose file with correct socket
    sed "s|/user/1000/docker.sock|$DOCKER_SOCK|g" docker-compose.yml > docker-compose.tmp.yml
    COMPOSE_FILE="docker-compose.tmp.yml"
else
    COMPOSE_FILE="docker-compose.yml"
fi

# Prepare required files
echo "Preparing files..."
./scripts/prepare-files.sh

# Create external network if it doesn't exist
docker network create traefik 2>/dev/null || true

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Generating environment file..."
    ./scripts/generate-env.sh
fi

# Check if password hash is generated
if grep -q "YOUR_PASSWORD_HASH_HERE" authelia/users_database.yml 2>/dev/null; then
    echo "WARNING: Password hash not set in authelia/users_database.yml"
    echo "Run: ./scripts/generate-password.sh to generate a hash"
    echo "Then update authelia/users_database.yml with the generated hash"
    echo ""
    echo "Continue anyway? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Deployment cancelled"
        exit 1
    fi
fi

# Stop existing containers
echo "Stopping existing containers..."
docker-compose -f "$COMPOSE_FILE" down

# Deploy with docker-compose
echo "Starting containers..."
docker-compose -f "$COMPOSE_FILE" up -d

# Clean up temporary file
if [ "$COMPOSE_FILE" = "docker-compose.tmp.yml" ]; then
    rm docker-compose.tmp.yml
fi

echo ""
echo "Stack deployed! Checking status..."
docker-compose ps

echo ""
echo "Checking logs for errors..."
docker-compose logs traefik | grep -E "(ERR|ERROR)" | tail -5

echo ""
echo "Services will be available at:"
echo "- Traefik Dashboard: https://traefik.yourdomain.com"
echo "- Authelia: https://auth.yourdomain.com"
echo "- Dashy Dashboard: https://dashboard.yourdomain.com"
echo ""
echo "To check logs: docker-compose logs -f [service-name]"
echo "To stop: docker-compose down"
