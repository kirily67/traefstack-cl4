#!/bin/bash

echo "Cleaning and restarting rootless Docker..."

# Stop all Docker processes
echo "Stopping all Docker processes..."
systemctl --user stop docker 2>/dev/null || true
pkill -u $(id -u) dockerd 2>/dev/null || true
pkill -u $(id -u) rootlesskit 2>/dev/null || true

# Wait a bit
sleep 3

# Clean up sockets and runtime files
echo "Cleaning up sockets and runtime files..."
rm -f /run/user/1000/docker.sock 2>/dev/null || true
rm -f /run/user/1000/docker.pid 2>/dev/null || true
rm -rf /run/user/1000/docker 2>/dev/null || true

# Remove the problematic directory if it exists
if [ -d "/user/1000/docker.sock" ]; then
    echo "Removing incorrect docker.sock directory..."
    rm -rf /user/1000/docker.sock
fi

# Set environment variables
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"

# Start Docker daemon without experimental flag
echo "Starting Docker daemon..."
dockerd-rootless.sh --host unix://$XDG_RUNTIME_DIR/docker.sock > /tmp/docker-daemon.log 2>&1 &

# Wait for daemon to start
echo "Waiting for daemon to start..."
sleep 10

# Check if socket was created
if [ -S "$XDG_RUNTIME_DIR/docker.sock" ]; then
    echo "✅ Docker socket created successfully at: $XDG_RUNTIME_DIR/docker.sock"
    
    # Test connection
    if docker info > /dev/null 2>&1; then
        echo "✅ Docker connection successful"
        echo "Docker version: $(docker --version)"
    else
        echo "❌ Docker connection failed"
        echo "Daemon logs:"
        tail -20 /tmp/docker-daemon.log
    fi
else
    echo "❌ Docker socket not created"
    echo "Daemon logs:"
    tail -20 /tmp/docker-daemon.log
fi
