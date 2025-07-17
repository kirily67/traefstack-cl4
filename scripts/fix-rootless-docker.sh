#!/bin/bash

echo "Fixing rootless Docker configuration..."

# Remove the incorrect directory
if [ -d "/user/1000/docker.sock" ]; then
    echo "Removing incorrect docker.sock directory..."
    rm -rf /user/1000/docker.sock
fi

# Stop user Docker service if running
echo "Stopping user Docker service..."
systemctl --user stop docker 2>/dev/null || true

# Kill any running dockerd processes
echo "Killing any running dockerd processes..."
pkill -u $(id -u) dockerd 2>/dev/null || true

# Clean up any existing sockets
echo "Cleaning up existing sockets..."
rm -f /run/user/1000/docker.sock 2>/dev/null || true
rm -f $HOME/.docker/run/docker.sock 2>/dev/null || true

# Ensure XDG_RUNTIME_DIR is set
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

# Create runtime directory if it doesn't exist
mkdir -p "$XDG_RUNTIME_DIR"

# Start Docker daemon in rootless mode
echo "Starting Docker daemon in rootless mode..."
dockerd-rootless.sh --experimental --host unix://$XDG_RUNTIME_DIR/docker.sock &

# Wait a bit for daemon to start
sleep 5

# Check if socket was created
if [ -S "$XDG_RUNTIME_DIR/docker.sock" ]; then
    echo "✅ Docker socket created at: $XDG_RUNTIME_DIR/docker.sock"
    
    # Test connection
    if DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock docker info > /dev/null 2>&1; then
        echo "✅ Docker connection successful"
    else
        echo "❌ Docker connection failed"
    fi
else
    echo "❌ Docker socket not created"
fi

echo ""
echo "Setting up environment variables..."
echo "export XDG_RUNTIME_DIR=\"$XDG_RUNTIME_DIR\"" >> ~/.bashrc
echo "export DOCKER_HOST=\"unix://$XDG_RUNTIME_DIR/docker.sock\"" >> ~/.bashrc

echo "Rootless Docker fix completed!"
echo "Please run: source ~/.bashrc"
