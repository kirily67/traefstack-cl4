#!/bin/bash

echo "=== Starting Docker manually (without systemd) ==="

# Stop and disable systemd service
systemctl --user stop docker.service 2>/dev/null || true
systemctl --user disable docker.service 2>/dev/null || true

# Kill existing processes
pkill -u $(id -u) dockerd 2>/dev/null || true
pkill -u $(id -u) rootlesskit 2>/dev/null || true
sleep 3

# Clean up
rm -rf /run/user/1000/dockerd-rootless/ 2>/dev/null || true
rm -f /run/user/1000/docker.sock 2>/dev/null || true

# Start Docker manually
echo "Starting Docker daemon..."
dockerd-rootless.sh --host unix:///run/user/1000/docker.sock > /tmp/docker-manual.log 2>&1 &

# Wait for it to start
sleep 15

# Check if it's working
if [ -S "/run/user/1000/docker.sock" ] && docker info > /dev/null 2>&1; then
    echo "✅ Docker started successfully!"
    echo "Docker version: $(docker --version)"
    echo "PID: $(pgrep -u $(id -u) dockerd)"
    
    # Keep it running
    echo "Docker is running in background. Logs in /tmp/docker-manual.log"
    echo "To stop: pkill -u $(id -u) dockerd"
else
    echo "❌ Docker failed to start"
    echo "Logs:"
    cat /tmp/docker-manual.log
fi
