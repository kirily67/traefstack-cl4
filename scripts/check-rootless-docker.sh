#!/bin/bash

echo "Checking Rootless Docker configuration..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to Docker daemon"
    echo "For rootless Docker, make sure Docker daemon is running for your user"
    echo "Check with: systemctl --user status docker"
    exit 1
fi

echo "Docker daemon is running ✓"

# Check Docker context
DOCKER_CONTEXT=$(docker context show 2>/dev/null)
echo "Docker context: $DOCKER_CONTEXT"

# Check for rootless Docker socket
POSSIBLE_SOCKETS=(
    "/user/1000/docker.sock"
    "$HOME/.docker/run/docker.sock"
    "/run/user/1000/docker.sock"
    "$XDG_RUNTIME_DIR/docker.sock"
)

DOCKER_SOCK=""
for sock in "${POSSIBLE_SOCKETS[@]}"; do
    if [ -S "$sock" ]; then
        DOCKER_SOCK="$sock"
        echo "Found Docker socket at: $sock ✓"
        break
    fi
done

if [ -z "$DOCKER_SOCK" ]; then
    echo "ERROR: Docker socket not found"
    echo "Searched in:"
    for sock in "${POSSIBLE_SOCKETS[@]}"; do
        echo "  $sock"
    done
    exit 1
fi

# Check socket permissions
ls -la "$DOCKER_SOCK"

# Check if running in rootless mode
if docker info 2>/dev/null | grep -q "rootless"; then
    echo "Docker is running in rootless mode ✓"
else
    echo "Docker might not be in rootless mode"
fi

echo ""
echo "Docker socket to use: $DOCKER_SOCK"
echo "Rootless Docker check completed!"
