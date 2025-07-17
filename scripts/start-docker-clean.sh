#!/bin/bash

echo "=== Starting Docker cleanly ==="

# Fix locks first
./scripts/fix-docker-lock.sh

# Wait a bit
sleep 3

# Set environment
export XDG_RUNTIME_DIR="/run/user/1000"
export DOCKER_HOST="unix:///run/user/1000/docker.sock"

# Start Docker via systemd
echo "Starting Docker via systemd..."
systemctl --user start docker.service

# Wait for service to start
sleep 10

# Check if service is running
if systemctl --user is-active docker.service &>/dev/null; then
    echo "✅ Docker service is active"
    
    # Check if socket exists
    if [ -S "/run/user/1000/docker.sock" ]; then
        echo "✅ Docker socket exists"
        
        # Test Docker
        if docker info > /dev/null 2>&1; then
            echo "✅ Docker is working!"
            echo "Docker version: $(docker --version)"
            echo "Docker info:"
            docker info | head -10
        else
            echo "❌ Docker socket exists but connection failed"
        fi
    else
        echo "❌ Docker socket not created"
    fi
else
    echo "❌ Docker service failed to start"
    echo "Status: $(systemctl --user status docker.service --no-pager -l)"
fi

echo "=== Docker startup completed ==="
